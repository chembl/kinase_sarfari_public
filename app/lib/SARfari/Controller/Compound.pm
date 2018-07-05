package SARfari::Controller::Compound;
# $Id: Compound.pm 602 2010-04-12 09:50:59Z sarfari $

# SEE LICENSE

use strict;
use warnings;
use Data::Dumper;
use Digest::MD5 qw(md5_hex);
use Carp;
use base 'SARfari::BaseController::Search';

sub auto : Private {
    my ( $self, $c ) = @_;

    $c->stash->{subtitle} = "Compound";
}

sub index : Private {
    my ( $self, $c ) = @_;

    $c->stash->{body} = "compound/cmpd_home.tt";

    # Get session search details
    $c->stash->{comp_session_search} =
        $c->model('SARfariDB::AppCmpdSearchJobs')->search(
        'me.session_id' => $c->sessionid,
        { order_by => "me.query_finish desc",
          rows     => 5,
        }
        );

    # Get selected compound sets
    $c->stash->{selected_sets} =
        $c->model('SARfariDB::AppCmpdSearchJobs')->search(
        {   'me.do_not_delete' => 1,
            'me.selected_set'  => 1
        },
        { order_by => "me.query_type" }
        );    

    # TODO: Delete excess session data
    # Have a maximun a 5 old queries saved
}

sub structure_search : Local {
    my ( $self, $c ) = @_;

    # Validate
    if ( !$c->req->params->{'molfile'} && !$c->req->params->{'smiles'}) {
        my $err = "User has not submitted structure";
        $c->detach( '/error/index', [$@] );
    }

    if ( $c->req->params->{'query_type'} !~
        qr{\A  Substructure|Flexmatch|Similarity  \z}xmsi ) {
        my $err = "Compound search query type not recognised";
        $c->detach( '/error/index', [$@] );
    }
    
    # Try convert smile
    my $chime = "";
    eval {
    	$chime = $c->model('SARfariDB::Dual')->molToChime($self->dbhQuote($c,$c->req->params->{'molfile'}));
    };

	# Try convert molfile
    if ($@) {
    	
    	eval { 
   			$chime = $c->model('SARfariDB::Dual')->smilesToChime($self->dbhQuote($c,$c->req->params->{'smiles'}));
    	};
    	
    	$chime = "", if($@);
    }
    
    my $cut_off    = $c->req->params->{'cut_off'} || 95;
    my $query_type = $c->req->params->{'query_type'}."-".$c->req->params->{'databaseSource'};

    # Check search has not already been run
    my $chime_inchikey = "";
    eval {
    	$chime_inchikey = $c->model('SARfariDB::Dual')->chimeToInchiKey($self->dbhQuote( $c, $chime ));
    };
    
    $chime_inchikey = undef, if($@);
    
    # Append similarity cut off, if sim based search to query type
    if ( $query_type =~ qr{\A  Similarity \z}xmsi ) {
        $query_type .= " ($cut_off)";
    }

    # Search job id - this is used to retrieve cached results
    my $jobid;

    # Run Search
    unless ( $jobid = $c->model('SARfariDB::AppCmpdSearchJobs')
        				->cached_query( $chime_inchikey, $query_type ) ) {
        	
        eval{
        	$jobid = $c->model('SARfariDB::Dual')->cmpdSearch(
        	    $self->dbhQuote( $c, $c->sessionid ),
        	    $self->dbhQuote( $c, $c->session->{username} ),
        	    $self->dbhQuote( $c, $chime ),
        	    $self->dbhQuote( $c, $chime_inchikey ),
        	    $self->dbhQuote( $c, $query_type ),
        	    $self->dbhQuote( $c, $c->req->params->{'databaseSource'} ),
        	    $cut_off
        	);
        };
        
        if($@){
        	# If search has failed job details are still stored - reuse cache method to retrieve        	
        	$jobid = $c->model('SARfariDB::AppCmpdSearchJobs')
        			   ->cached_query( $chime_inchikey, $query_type );
        }
    }

    # Forward to default display
    $c->detach( 'createWEB', [$jobid] );
}

# Process data from text based compound search

sub processData : Private {
    my ( $self, $c ) = @_;

    # Get search job_id
    $c->stash->{jobid} = $c->model('SARfariDB::Dual')->getJobid;
    my $query_type = "Text (" . $c->req->params->{'compoundType'} . ")";

    # If we have data, load it
    if ( $c->stash->{data}->{compound} ) {

        # Load bio search details
        # Q. Why load into bio table when conducting compound search?
        # A. Becuase comp id cache table is FK constrained to bio jobs
        #    table, due to delete cascade when session data wiped. (Real
        #    reason is bad design, this is a 'fix')
        $c->model("SARfariDB::AppBioSearchJobs")->create(
            {   job_id     => $c->stash->{jobid},
                session_id => "",
                username   => "",
                query_type => $c->stash->{'display_query_string'}
            }
        );

        # Note that $c->stash->{'display_query_string'} is generatated in
        # pullData (Search.pm)

        # Load comp ids
        $c->forward( 'loadData', ['compound'] );

        # Get all compound data
        $c->model('SARfariDB::Dual')->cmpdSearchTxt(
            $c->stash->{jobid},
            $self->dbhQuote( $c, $c->sessionid ),
            $self->dbhQuote( $c, $c->session->{username} ),
            $self->dbhQuote( $c, $query_type ),
            $self->dbhQuote( $c, $c->stash->{'display_query_string'} ),
            $self->dbhQuote( $c, $c->req->params->{'databaseSource'} )
        );
    }

    # Forward to default display
    $c->detach( 'createWEB', [ $c->stash->{jobid} ] );
}

# Private method for displaying paged compound data

sub results : LocalRegex('results/(\d+)/(\d+)/(\w+)/(\w+)/(\w+)?$') {
    my ( $self, $c ) = @_;

    my ( $jobid, $page, $sorted_on, $sort_way, $view ) =
        @{ $c->request->snippets };

    # Test column being sorted on exists
    unless ( $c->model("SARfariDB::AppCmpdSearchCache")
        ->result_source->has_column($sorted_on) ) {
        Catalyst::Exception->throw(
            "Column is not defined in table: $sorted_on");
    }

    # Check $sort_way is supplied correctly
    unless ( $sort_way =~ qr{\A  (asc|desc)  \z}xmsi ) {
        Catalyst::Exception->throw(
            "Unexpected value supplied for column sort direction: $sort_way"
        );
    }

    # Setup stash
    $c->stash->{jobid}     = $jobid;
    $c->stash->{sorted_on} = $sorted_on;
    $c->stash->{sort_way}  = $sort_way;
    $c->stash->{page}      = $page;
    $c->stash->{view}      = $view;

    # I.E. does not handle embed tags well so limit page size to 30
    my $DEFAULT_PAGE_SIZE =
        ( $c->request->browser->windows && $c->request->browser->ie )
        ? 30
        : 90;

    # Get cached results
    $c->stash->{comp_details} =
        $c->model("SARfariDB::AppCmpdSearchCache")->search(
        'me.job_id' => $c->stash->{jobid},
        {   rows     => $DEFAULT_PAGE_SIZE,
            page     => $c->stash->{page},
            order_by => "me\."
                . $c->stash->{sorted_on} . " "
                . $c->stash->{sort_way}
                . " NULLS LAST",
        }
        );

    # Get job details
    $c->stash->{comp_search_details} =
        $c->model('SARfariDB::AppCmpdSearchJobs')->find( $c->stash->{jobid} );

    # Setup pager
    $c->stash->{pager} = $c->stash->{comp_details}->pager;

    # Table or Mini-Report Card
    my $cmpd_view = ( $c->stash->{view} eq "mini" ) ? "mini" : "table";

    # Body just contains menu
    $c->stash->{body} = "compound/cmpd_search_results.tt";

    # Data template
    $c->stash->{cmpd_view} = "compound/cmpd_view\_$cmpd_view.tt";
}

# Regex used to direct user to report card bioactivity results

sub report : LocalRegex('report/(\w+)/(\d+)/(\w+)$') {
    my ( $self, $c ) = @_;

    my ( $db_source, $id, $compound_type ) = @{ $c->request->snippets };

    # Set up pseudo body parameters
    $c->req->params->{'compoundType'}   = $compound_type;
    $c->req->params->{'compoundList'}   = $id;
    $c->req->params->{'databaseSource'} = $db_source;

    $c->detach("search");
}

# Priavte method for creating compound sdf download

sub createSDF : Private {
    my ( $self, $c, $jobid ) = @_;

    my @download       = ();
    my @sdf_attributes =
        qw/ alogp hba hbd psa ro3_pass num_ro5_violations rtb/;

    # SDF query
    my $sdf_rs = $c->model("SARfariDB::AppCmpdSearchCache")->search(
        'me.job_id' => $jobid,
        {   join   => [ 'compound' ],
        	select => [ { molfile => 'compound.ctab' },'compound.sarregno','compound.molweight', @sdf_attributes ],        	
            as => [ 'molfile', 'sarregno', 'molweight', @sdf_attributes ]
        }
    );
		
    # Local block used to contain warning switch off as nulls can be returned
    # from db query
    {
        no warnings 'uninitialized';

        while ( my $r = $sdf_rs->next ) {
            my $sdf .= $r->get_column('molfile');
            $sdf =~ s/\n$//;    # molfiles sometimes have unexpected \n$

            $sdf .= "\n> <sarregno>\n"  . $r->get_column('sarregno') . "\n\n";
            $sdf .= "\n> <molweight>\n" . $r->get_column('molweight') . "\n\n";
            
            foreach my $sdf_attr (@sdf_attributes) {
            	$sdf_attr =~ s/^me.//xms;
                $sdf .=
                    "\n> <$sdf_attr>\n" . $r->get_column($sdf_attr) . "\n\n";
            }

            $sdf .= "\$\$\$\$";

            push( @download, $sdf );
        }
    }

    my $filename = "cmpd_download\_$jobid.sdf";

    $c->res->header( 'Content-Disposition',
        qq[attachment; filename="$filename"] );
    $c->res->content_type('text/plain');
    $c->res->body( join( "\n", @download ) );
}

# Priavte method for creating compound txt download

sub createTXT : Private {
    my ( $self, $c, $jobid ) = @_;

    # Do not want to return chime string
    # ! Not to sure about side effects, needs testing
    $c->model('SARfariDB::AppCmpdSearchCache')
        ->result_source->remove_column('chime_string');

    # Set up download with header information
    my $download = join( "\t",
        $c->model('SARfariDB::AppCmpdSearchCache')->result_source->columns )
        . "\n";

    # Local block used to contain warning switch off as nulls can be returned
    # from db query
    {
        no warnings 'uninitialized';

        $download .= join( "\n",
            map { join( "\t", @{$_} ) }
                $c->model("SARfariDB::AppCmpdSearchCache")
                ->search( 'me.job_id' => $jobid )->cursor->all );
    }

    # Add chime string back to table definition
    $c->model('SARfariDB::AppCmpdSearchCache')
        ->result_source->add_column(
        'chime_string' => { data_type => 'varchar2', is_nullable => 0 } );

    my $filename = "cmpd_download\_$jobid.txt";

    $c->res->header( 'Content-Disposition',
        qq[attachment; filename="$filename"] );
    $c->res->content_type('text/plain');
    $c->res->body($download);
}

# Priavte method used to forward to compound search results

sub createWEB : Private {
    my ( $self, $c, $jobid ) = @_;

    # Used to get query type at last minute, as default sort is different for
    # similarity search
    my $job_detials = $c->model('SARfariDB::AppCmpdSearchJobs')->find($jobid);

    # Check data is associated with supplied job
    if ( !$job_detials ) {
    	$c->res->redirect(
        	$c->uri_for(
            	"/compound/results/$jobid/1/molweight/asc/mini")
    	);
    	
    	$c->detach();
    }

    # Defaults
    my $page      = 1;
    my $sorted_on =
        ( $job_detials->query_type =~ m/^Similarity/ )
        ? "similarity"
        : "molweight";
    my $sort_way = "asc";
    my $view     = "mini";

    $c->res->redirect(
        $c->uri_for(
            "/compound/results/$jobid/$page/$sorted_on/$sort_way/$view")
    );
    $c->detach();
}

# Priavte method used to forward user to bio search results 
# ! Currently not used in application

sub createBIOAll : Private {
    my ( $self, $c, $jobid ) = @_;

    # Used to get query type at last minute, as default sort is different for
    # similarity search
    my $job_detials = $c->model('SARfariDB::AppCmpdSearchJobs')->find($jobid);

    # Check data is associated with supplied job
    if ( !$job_detials ) {
        Catalyst::Exception->throw(
            "Job id: $jobid, is not associated with any data");
    }

    # Check to see if bio dat has not already been loaded
    # ! If check not carried out unique constraint on bio jobs table
    # ! may be broken
    my $job_detials_bio =
        $c->model('SARfariDB::AppBioSearchJobs')->find($jobid);

    # If data not loaded - load it
    if ( !$job_detials_bio ) {

        # Set up some defaults
        $c->stash->{jobid}      = $jobid;
        $c->stash->{searchType} = "Compound";

        # Load bio search details
        $c->model("SARfariDB::AppBioSearchJobs")->create(
            {   job_id     => $c->stash->{jobid},
                session_id => $c->sessionid,
                username   => $c->session->{username},
                query_type => $c->stash->{searchType}
            }
        );

        # Move compound table data to bio table data
        $c->model('SARfariDB::Dual')->cmpdToBio( $c->stash->{jobid} );

        # Load bioactivity data into cache
        $c->model('SARfariDB::Dual')->bioSearch(
            $c->stash->{jobid},
            $self->dbhQuote( $c, $c->stash->{searchType} ),
            $self->dbhQuote( $c, $c->stash->{bioFilters} )
        );
    }

    $c->res->redirect(
        $c->uri_for("/bioactivity/results/$jobid/1/display_name/asc") );

    $c->detach();
}

# Priavte method used to forward user to bio search

sub createBIO : Private {
    my ( $self, $c, $jobid ) = @_;

    # Used to get query type at last minute, as default sort is different for
    # similarity search
    my $job_detials = $c->model('SARfariDB::AppCmpdSearchJobs')->find($jobid);

    # Check data is associated with supplied job
    if ( !$job_detials ) {
        Catalyst::Exception->throw(
            "Job id: $jobid, is not associated with any data");
    }

    # Check to see if bio dat has not already been loaded
    # ! If check not carried out unique constraint on bio jobs table
    # ! may be broken
    my $regnos =
        $c->model('SARfariDB::AppCmpdSearchCache')->get_job_compounds($jobid);
    
    $c->stash->{regnos}        = join( "\n", @{$regnos} );
    $c->stash->{bioTabDisplay} = "compound";
    
    $c->detach( '/bioactivity/index');    
}

# Priavte method used to get compound registration numbers

sub createREG : Private {
    my ( $self, $c, $jobid ) = @_;

    # Used to get query type at last minute, as default sort is different for
    # similarity search
    my $job_detials = $c->model('SARfariDB::AppCmpdSearchJobs')->find($jobid);

    # Check data is associated with supplied job
    if ( !$job_detials ) {
        Catalyst::Exception->throw(
            "Job id: $jobid, is not associated with any data");
    }

    # Check to see if bio dat has not already been loaded
    # ! If check not carried out unique constraint on bio jobs table
    # ! may be broken
    my $regnos =
        $c->model('SARfariDB::AppCmpdSearchCache')->get_job_compounds($jobid);
    
    my $filename = "regno_download\_$jobid.txt";

    $c->res->header( 'Content-Disposition',
    qq[attachment; filename="$filename"] );
    $c->res->content_type('text/plain');
    $c->res->body( join( "\n", @{$regnos} ));     
}

# Priavte method used to forward to compound search results

sub deleteJobId : Private {
    my ( $self, $c, $jobid ) = @_;

    # Delete user selected compound search data
    $c->model('SARfariDB::AppCmpdSearchJobs')->find($jobid)->delete;

    $c->res->redirect( $c->uri_for("/compound") );
    $c->detach();
}

sub molfile : Regex('compound/molfile/(\d+)$') {
    my ( $self, $c ) = @_;
    my ( $sarregno ) = @{ $c->request->snippets };

    # Get cached results
    my $molfile = [$c->model("SARfariDB::CompoundMols")->search(
        'me.sarregno' => $sarregno,
        { select   => [ { molfile => 'ctab' }]}
    )->cursor->all]->[0]->[0];
    
    $c->res->output($molfile);
}

sub image : Regex('compound/image/(\d+).png$') {
    my ( $self, $c ) = @_;
    my ( $sarregno ) = @{ $c->request->snippets };

    # Get cached results
    my $image = $c->model("SARfariDB::CompoundImages")->find($sarregno)->image;

    $c->response->content_type('image/png');
    $c->response->header('Cache-Control' => 'max-age=' . $c->config->{compound_cache_control});
    $c->response->output($image);
}

sub display : Regex('compound/display/(\d+)$') {
    my ( $self, $c ) = @_;
    my ( $sarregno ) = @{ $c->request->snippets };
	
	my $molfile = [$c->model("SARfariDB::CompoundMols")->search(
        'me.sarregno' => $sarregno,
        { select   => [ { molfile => 'ctab' }]}
    )->cursor->all]->[0]->[0];
    
    # JME viewer requires molfile string
    $molfile =~ s/\n/\|/g;
    
    $c->stash->{molfile} = $molfile;
	$c->stash->{simple}  = 1;
	$c->stash->{body}    = "compound/cmpd_display.tt";	    
}

sub convertmolfile : Local{
    my ( $self, $c ) = @_;
	
	my $molfile = $c->req->params->{'data'};
    
    # JME viewer requires molfile string
    $molfile =~ s/\n/\|/g;
    
    $c->res->output($molfile);	    
}

sub convertsmiles : Local{
    my ( $self, $c ) = @_;
	
	my $smiles = $c->req->params->{'data'};
    my $molfile;
    
    eval { 
   		$molfile = $c->model('SARfariDB::Dual')->smilesToMolfile($self->dbhQuote($c,$smiles));
    };
    	
    # JME viewer requires molfile string
    $molfile =~ s/\n/\|/g;
    
    $c->res->output($molfile);	    
}

sub sketch : Local {
    my ( $self, $c ) = @_;
    
	$c->stash->{simple}  = 1;
	$c->stash->{sketch}  = 1;
	$c->stash->{body}    = "compound/cmpd_display.tt";	    
}

1;
