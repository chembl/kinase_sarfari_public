package SARfari::Controller::Protein;
# $Id: Protein.pm 175 2009-08-26 13:39:38Z mdavies $

# SEE LICENSE

use strict;
use warnings;
use base 'SARfari::BaseController::Search';
use Data::Dumper;
use SARfari::External::BLAST::Simple;
use SARfari::External::Alignment::Simple;

sub auto : Private {
    my ( $self, $c ) = @_;

    $c->stash->{subtitle} = "Protein";
}

sub index : Private {
    my ( $self, $c ) = @_;

    $c->stash->{body} = "protein/prot_home.tt";
}

# Get blast alignment from file

sub blastaln : LocalRegex('blastaln/(\d+)/(\d+)$') {
    my ( $self,     $c )      = @_;
    my ( $blast_id, $dom_id ) = @{ $c->request->snippets };

    my $filename = $c->config->{tmpdir} . "/$blast_id\.fa.blast";

    open my $fh, '<', $filename
        or Catalyst::Exception->throw("Can not open file: $filename");

    # Get selected alignment
    my @aln = grep { $_ =~ "^$dom_id\_" } do { local $/ = "\n>"; <$fh> };

    close $fh;

    # Only expecting 1 hit
    if ( scalar(@aln) == 1 ) {

        # If last hit remove db stats
        if ( $aln[0] =~ m/Database:/m ) {
            $aln[0] =~ s/(Database\:.*?$)//xs;
        }

        $c->response->body(
            "<html><body><pre>>" . $aln[0] . "</pre></body></html>" );
    }
    else {

        # We should not get here, throw error
        Catalyst::Exception->throw(
            "Error parsing blast file, could not find selected alignment");
    }
}

sub processData : Private {
    my ( $self, $c ) = @_;
    
    my $params = {
        taxid => $c->req->params->{'taxid'} || undef
    };
    
    # Get protein target data
    
    $c->stash->{target_accessions} = {};
    
    if ( $c->stash->{data}->{target} ) {
        foreach my $batch ( @{ $c->stash->{data}->{target} } ) {
            push(
                @{ $c->stash->{target_details} },
                grep {$_} @{
                    $c->model('SARfariDB::ProtDomain')->getProtDetails(
                        $batch, $params
                        )    
                    }
            );
            
            my $accs = $c->model('SARfariDB::ProtAccession')->getAccessionDetails(
            	$batch, $params
            );
                        
            @{$c->stash->{target_accessions}}{keys %{$accs}} = values %{$accs};            
        }
    }
    
    # View Results
    $c->stash->{body} = "protein/prot_search_results.tt";
}

sub runBlast : Private {
    my ( $self, $c ) = @_;

    #Check fasta supplied
    unless ( $c->req->params->{'targetList'} ) {
        Catalyst::Exception->throw("FASTA has not been submitted");
    }

    #Blast identifier
    $c->stash->{blast_id} = int( rand(1000000) );

    #Check fasta sequence is well formatted
    my $sequence =
        $c->forward( 'checkFasta', [ $c->req->params->{'targetList'} ] );

    my $database = $c->config->{home} . "/root/data/fasta/sarfari_fasta";
    my $in_file  = $c->config->{tmpdir} . "/" . $c->stash->{blast_id} . ".fa";
    my $out_file = $in_file . ".blast";
    $c->forward( 'writeTempFile', [ $in_file, $sequence ] );

    my $command =
          $c->config->{blast}->{exe} . " -F F " . " -e "
        . $c->config->{blast}->{eval}
        . " -p blastp " . " -d "
        . $database . " -i "
        . $in_file
        . " -b 200 "
        . " -v 0 " . " -o "
        . $out_file;

    #Run blast command
    system($command);

    #If error occurrs attempted command will be printed to debug screen
    $c->stash->{command} = $command;

    #Parse the blast results
    my $ids = $c->forward( 'parseBlast', [$out_file] );

    # Get all details associated with blast hits
    $c->stash->{target_accessions} = {};
    
    if ( scalar( @{$ids} ) > 0 ) {
        $c->stash->{prot_details} =
            { map { $_->{dom_id} => $_ }
                @{ $c->model('SARfariDB::ProtDomain')->getProtDetails($ids) }
            };
            
        my $accs = $c->model('SARfariDB::ProtAccession')->getAccessionDetails(
         	$ids
        );
                        
        @{$c->stash->{target_accessions}}{keys %{$accs}} = values %{$accs};               
    }

    # View Results
    $c->stash->{body} = "protein/prot_blast_results.tt";
}

# Private method used to parse blast results

sub parseBlast : Private {
    my ( $self, $c, $outfile ) = @_;

    my $blast_simple = SARfari::External::BLAST::Simple->new($outfile);

    my $ids = [];
    return $ids, if(!$blast_simple->get_query_length || $blast_simple->get_query_length <= 0);

    # Determine unit size for query sequence - required for drawing blast image
    my $unit =
        $c->config->{blast}->{bar_width} / $blast_simple->get_query_length;

    $c->stash->{query_length} = $blast_simple->get_query_length;
    $c->stash->{unit}         =
        $c->config->{blast}->{bar_width} / $c->stash->{query_length};

    # Blast hit counter
    my $i = 0;

    # Loop through each hit to query sequence
    while ( my $hit = $blast_simple->next ) {
        $i++;

        $hit->get_name =~ m/^(\d+)/;
        my $dom_id = $1;

        push( @{$ids}, $dom_id );

        my $hit_details = {
            id      => $dom_id,
            name    => $hit->get_name,
            hit_len => $hit->get_length,
            display => $i > 50 ? 0 : 1,
            hsps    => [],
            count   => $i
        };

        # Loop through each high-scoring-pair (hsp)
        while ( my $hsp = $hit->next ) {

            my $img_margin =
                  $hsp->get_query_from == "1"
                ? $c->config->{blast}->{indent}
                : ( $unit * $hsp->get_query_from ) +
                $c->config->{blast}->{indent};

            my $img_length = (
                ( $unit * ( $hsp->get_query_to - $hsp->get_query_from + 1 ) )
                + $img_margin - $c->config->{blast}->{indent} ) <=
                $c->config->{blast}->{bar_width}
                ? ( $unit * ( $hsp->get_query_to - $hsp->get_query_from ) )
                : $c->config->{blast}->{bar_width} +
                $c->config->{blast}->{indent} - $img_margin;

            # Helps tidy up overlaps in image
            if ( $img_margin > $c->config->{blast}->{indent} ) {
                $img_margin += 1;
            }

            my $hsp_details = {
                evalue     => $hsp->get_evalue,
                identity   => int( $hsp->get_identity ),
                qry_start  => $hsp->get_query_from,
                qry_end    => $hsp->get_query_to,
                hit_start  => $hsp->get_subject_from,
                hit_end    => $hsp->get_subject_to,
                img_margin => int($img_margin),
                img_length => int($img_length),
                img_height => $i * $c->config->{blast}->{newline},
                colour     => id2colour( $hsp->get_identity )
            };

            push( @{ $hit_details->{hsps} }, $hsp_details );
        }
        push( @{ $c->stash->{blastresults} }, $hit_details );
    }

    return $ids;
}

# Valiadtes user supplied fasta

sub checkFasta : Private {
    my ( $self, $c, $user_fasta ) = @_;

    my @tmp = split( '\n', $user_fasta );

    my $line_count    = 0;
    my $seqline_count = 0;
    my @fasta         = ();
    my $err           = 0;
    foreach my $line (@tmp) {
        $line_count++;
        if ( $line_count == 1 ) {
            if ( $line =~ /^>/ ) {
                push( @fasta, $line )
                    ;    # Found header 'push' and move to next line
                next;
            }
            push( @fasta, ">" );    # Else, add '>' and continue
        }

        $line =~ s/\s//g;

        if ( $line =~ /[^A-Za-z]/ && length($line) > 0 ) {
            $err = 1;
            next;
        }

        if ( length($line) > 0 ) {
            push( @fasta, $line );
            $seqline_count++;
        }
    }

    # Check fasta supplied
    if ( $err || scalar(@fasta) == 0 || $seqline_count == 0 ) {
        Catalyst::Exception->throw("FASTA Sequence Format Error");
    }

    return join( "\n", @fasta );
}

# Priavte method for creating compound txt download

sub createBIOALL : Private {
    my ( $self, $c, $jobid ) = @_;

    # We have ids just get the bioactivities

    $c->stash->{searchType} = "target";

    $c->detach('/bioactivity/processData');
}


# Priavte method used to forward user to bio search

sub createBIO : Private {
    my ( $self, $c, $jobid ) = @_;
    
    $c->detach( '/bioactivity/index');    
}


# Priavte method for creating compound txt download

sub createSEQ : Private {
    my ( $self, $c ) = @_;

    # Get fasta
    my $fasta = [];

    if ( $c->stash->{data}->{target} ) {
        foreach my $batch ( @{ $c->stash->{data}->{target} } ) {
            push(
                @{$fasta},
                grep {$_}
                    @{ $c->model('SARfariDB::Alignment')->fasta($batch) }
            );
        }
    }

    my $filename = "fasta.txt";

    $c->res->header( 'Content-Disposition',
        qq[attachment; filename="$filename"] );
    $c->res->content_type('text/plain');
    $c->res->body( join( '', @{$fasta} ) );
}

# Priavte method for creating compound txt download

sub createALN : Private {
    my ( $self, $c ) = @_;

    # Get fasta
    my $aln_seqs = [];

    if ( $c->stash->{data}->{target} ) {
        foreach my $batch ( @{ $c->stash->{data}->{target} } ) {
            push(
                @{$aln_seqs},
                grep {$_} @{ $c->model('SARfariDB::Alignment')->aln($batch) }
            );
        }
    }
    
    my $site =  $c->req->params->{site} || 3; #default to canonical binding site    
    my $site_name = get_site_name($site);
    my $site_positions = [$c->model('SARfariDB::SiteDefinitions')
    	->search(site_id => $site)
    	->get_column('aln_pos')
    	->all];       

    my $alignment = SARfari::External::Alignment::Simple
    	->new( join( '', @{$aln_seqs} ), $site_name, $site_positions);

    my $filename = "alignment.txt";

    $c->res->header( 'Content-Disposition',
        qq[attachment; filename="$filename"] );
    $c->res->content_type('text/plain');
    $c->res->body( $alignment->display );
}

# Get short versions of site name

sub get_site_name {
	my $site = shift;
	
	my $site_names = {
		1 => 'P38 Site',
		2 => 'PKA Site',
		3 => 'Canonical Site',
		4 => 'MEK2 Site',
		5 => 'Gleevec Site',
	};
	
	return $site_names->{$site};
}

# Convert id to appropriate display colour

sub id2colour {
    my $id = shift;

    if ( $id >= 80 ) {
        return "firebrick";
    }
    elsif ( $id < 80 && $id >= 55 ) {
        return "navy";
    }
    elsif ( $id < 55 && $id >= 30 ) {
        return "seagreen";
    }
    elsif ( $id < 30 && $id >= 20 ) {
        return "salmon";
    }
    else {
        return "gray";
    }
}

1;
