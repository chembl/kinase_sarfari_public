package SARfari::BaseController::Search;
# $Id: Search.pm 526 2010-01-22 13:33:18Z mdavies $

# SEE LICENSE

use strict;
use warnings;
use base 'Catalyst::Controller';
use Data::Dumper;
use Catalyst::Exception;
use Scalar::Util qw (blessed reftype);
use IO::File;

sub search : Local {
    my ( $self, $c ) = @_;

    # Determine search type

    if (   $c->req->params->{'compoundType'}
        && $c->req->params->{'targetType'} ) {
        $c->stash->{searchType} = "compound_target";
    }
    elsif ( $c->req->params->{'targetType'} ) {            
        $c->stash->{searchType} = "target";
    }
    elsif ( $c->req->params->{'compoundType'} ) {
        $c->stash->{searchType} = "compound";
    }
    else {
        Catalyst::Exception->throw("Search type not defined");
    }

    # If blast, branch off early
    if ( $c->req->params->{'targetType'} eq 'seq' ) {
        $c->detach('runBlast');
    }
    
    # Different search type
    if ( $c->req->params->{'targetType'} =~ /pdblig|pdb|px/ ) {
        $c->detach('structureSearch');
    }

    $c->detach('prepareSearch');
}

# Method forwards user to appropriate function

sub function : LocalRegex('function/(\w+)(/(\d+))?$') {
    my ( $self, $c ) = @_;

    my ( $function, $jobid ) = @{ $c->request->snippets };

    $jobid =~ s/\///, if(defined $jobid); # Remove '/' from jobid

    if ( $function eq "del" ) {
        $c->detach( 'deleteJobId', [$jobid] );
    }

    # See if any params have been passed, batch if true
    if ( $c->req->params->{'selectedDomids'} ) {

        my $tmp_aref =
            ( reftype $c->req->params->{'selectedDomids'} eq "ARRAY" )
            ? $c->req->params->{'selectedDomids'}
            : [ $c->req->params->{'selectedDomids'} ];

        # For bio search
        $c->stash->{domids} = join( "\n",  @{$tmp_aref});
        
        # For bio all search
        $c->stash->{data}->{target} =
            $c->forward( 'createBatches', [$tmp_aref] );
        
    }

    $c->detach( 'create' . uc($function), [$jobid] );
}


sub prepareSearch : Private {

    my ( $self, $c ) = @_;

    # Deterime user input data type
    my $compound_data;
    my $target_data;

    # Check we have compound input data and process
    if ( $c->stash->{searchType} =~ /compound|compound_target/ ) {

        # Is conversion required (i.e. not numeric)
        my $conversion_method =
            ( $c->req->params->{'compoundType'} eq "regno" )
            ? 0
            : $c->req->params->{'compoundType'} . "ToRegno";

        # Create search data structure
        $c->stash->{data}->{compound} =
            $c->forward( 'createData', [ "compound", $conversion_method ] );

    }

    # Check we have target input data and process
    if ( $c->stash->{searchType} =~ /target|compound_target/ ) {

        # Is conversion required (i.e. not numeric)
        my $conversion_method =
            ( $c->req->params->{'targetType'} eq "domid" )
            ? 0
            : $c->req->params->{'targetType'} . "ToDomid";

        # Create search data structure
        $c->stash->{data}->{target} =
            $c->forward( 'createData', [ "target", $conversion_method ] );
    }

    # Got data now do something with it
    $c->detach('processData');
}

#

sub createData : Private {
    my ( $self, $c, $datatype, $conversion_method ) = @_;

    # Parse and validate data
    my $tmp_aref = $c->forward(
        'parseData',
        [   [ split( /\n+/, $c->forward( 'pullData', [$datatype] ) ) ],
            $datatype, $conversion_method
        ]
    );

    # If no data has passed validation stage
    #unless ( @{$tmp_aref} ) {
    #    $c->detach('/error/index', ["The query has returned 0 results"]);
    #    # Catalyst::Exception->throw(
    #    #     "No valid $datatype data has been submitted");
    #}
		
    return $c->forward( 'createBatches', [$tmp_aref] );
}

# 'Batchify' arrayref

sub createBatches : Private {
    my ( $self, $c, $aref ) = @_;

    my $ret_aref;

    # Divide array into blocks
    my $ARRAY_BATCH_SIZE = 100;

    while ( scalar( @{$aref} ) > 0 ) {
        push( @{$ret_aref}, [ splice( @{$aref}, 0, $ARRAY_BATCH_SIZE ) ] );
    }

    return $ret_aref;
}

#

sub parseData : Private {
    my ( $self, $c, $data_aref, $datatype, $conversion_method ) = @_;

    my $DRY_IDS = {};

    foreach my $d ( @{$data_aref} ) {
    	
    	$d =~ s/[\r\n]+//g;
    	$d =~ s/^\s+//g;
    	        
        # The following logic is messy, needs 'cleaning'
        
        # Skip conversion conditions
        # 1. No conversion has to be number
        next, if ( !$conversion_method && $d !~ /^\d+$/ );

        # 2. Query has to be > 2 chars, unless listed below
        next,
            if (
            $conversion_method
            && (   $conversion_method ne "domidToRegno"
                && $conversion_method ne "domidIC50ToRegno"
                && $conversion_method ne "domidKiToRegno"
                && $conversion_method ne "extToRegno" )
            && length($d) <= 2
            );

        # 3. If conversion is domidToRegno, has to be number
        next,
            if (
            (      $conversion_method eq "domidToRegno"
                || $conversion_method eq "domidKiToRegno"
                || $conversion_method eq "domidIC50ToRegno"
            )
            && $d !~ /^\d+$/
            );

        # May need to convert user input to domid/molid
        if ($conversion_method) {

            # Decide which table to call method on
            my $table =
                ( $datatype eq 'target' )
                ? "ProtDomain"
                : "CompoundDictionary";

            foreach my $converted_id (
                @{ $c->model("SARfariDB::$table")->$conversion_method($d) } )
            {
                $DRY_IDS->{$converted_id} = 1;
            }
        }

        # If conversion not need, just add to return data structure
        else {
            $DRY_IDS->{$d} = 1;
        }
    }

  # TODO: Possibly restrict target ids for bioactivity searches as not all are
  # associated with bioactivity data points

    my $ret_aref = [ keys %{$DRY_IDS} ];

    return $ret_aref;    
}

# Get pasted or uploaded data

sub pullData : Private {
    my ( $self, $c, $datatype ) = @_;

    my $data =
        ( $c->req->params->{ $datatype . 'List' } )
        ? $c->req->params->{ $datatype . 'List' }
        : ( $c->req->params->{ $datatype . 'File' } )
        ? $c->req->upload( $datatype . 'File' )->slurp
        : Catalyst::Exception->throw("$datatype data has not been submitted");

    my $data_format = reftype $data;

    # Check for array in case data has come from multiple select boxes
    # This occurs when

    my $ret =
        ( $data_format && $data_format eq "ARRAY" )
        ? join( ' ', @{$data} )
        : $data;

    # Make query string
    $c->stash->{'display_query_string'} =
        ( length($ret) > 20 ) ? substr( $ret, 0, 18 ) . ".." : $ret;

    return $ret;
}

# Load target or compound ids into appropriate bioactivity cache table

sub loadData : Private {
    my ( $self, $c, $load_data_type ) = @_;

    foreach my $batch ( @{ $c->stash->{data}->{$load_data_type} } ) {

        $c->model('SARfariDB::Dual')->bulkIdInsert(
            $c->stash->{jobid},
            $self->dbhQuote( $c, join( ', ', @{$batch} ) ),
            $self->dbhQuote( $c, $load_data_type )
        );
    }
}

# DBI::quote shortcut

sub dbhQuote : Private {
    my ( $self, $c, $str ) = @_;

    return $c->model('SARfariDB::Dual')
        ->result_source->schema->storage->dbh->quote($str);
}

# Write temp file, pretty obvious

sub writeTempFile : Private {

    my ( $self, $c, $filename, $data ) = @_;

    my $fh = new IO::File "> $filename";
    if ( defined $fh ) {
        print $fh "$data\n";
        $fh->close;
    }
}

1;
