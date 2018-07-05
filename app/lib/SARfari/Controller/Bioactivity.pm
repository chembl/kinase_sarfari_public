package SARfari::Controller::Bioactivity;
# $Id: Bioactivity.pm 804 2013-02-18 16:09:48Z mdavies $

# SEE LICENSE

use strict;
use warnings;
use Data::Dumper;
use Catalyst::Exception;
use List::MoreUtils qw( mesh uniq );

use base 'SARfari::BaseController::Search';

sub auto : Private {
    my ( $self, $c ) = @_;

    $c->stash->{subtitle} = "Bioactivity";
}

sub index : Private {
    my ( $self, $c ) = @_;

    $c->stash->{body} = "bioactivity/bio_home.tt";
}

# Responds to ajax request for activity types - return format is json

sub activity_request : Local {
    my ( $self, $c ) = @_;

    if ( $c->req->params->{id} ) {

        #Run query
        my $search_rs =
            $c->model('SARfariDB::AppActivitiesToDomains')
            ->search( 'me.dom_id' => $c->req->params->{id} );

        my $ACTIVITY_TYPE_DRY = {};

        while ( my $s = $search_rs->next ) {
            $ACTIVITY_TYPE_DRY->{ $s->activity_type } = 1;
        }

        my @json =
            map {"{optionValue:\'$_\', optionDisplay: \'$_\'}"}
            keys %{$ACTIVITY_TYPE_DRY};

        $c->res->body( '[' . join( ",", @json ) . ']' );
    }

}

# Responds to ajax request for target names - returns format is json

sub target_request : Local {
    my ( $self, $c ) = @_;

    if ( $c->req->params->{target} ) {

        my $filter =
            " upper(me.gene_domain_name) like '"
            . uc( $c->req->params->{target} ) . "%' ";

        #Run query
        my $search_rs =
            $c->model('SARfariDB::AppActivitiesToDomains')
            ->search_literal($filter);

        my $TARGET_DRY = {};

        while ( my $s = $search_rs->next ) {
            $TARGET_DRY->{ $s->dom_id } = $s->display_name;
        }

        my @json =
            map {"{optionValue:\'$_\', optionDisplay: \'$TARGET_DRY->{$_}\'}"}
            keys %{$TARGET_DRY};

        $c->res->body( '[' . join( ",", @json ) . ']' );
    }

}

# Ajax auto-complete response

sub auto_target : Local {

    my ( $self, $c ) = @_;

	# Remove non word characters
    $c->req->params->{'q'} =~ s/\W//g;
		
    my $filter =
        " upper(me.gene_domain_name) like '"
        . uc( $c->req->params->{'q'} ) . "%' ";

    my $target_names = join(
        "\n",
        map { $_->[0] }
            $c->model('SARfariDB::AppActivitiesToDomains')->search(
            { 'me.assay_type' => 'B' },                       
            { select => { distinct => 'me.gene_domain_name' } }
            )->search_literal($filter)->cursor->all
    );

    $c->res->body($target_names);
}

# Process and load cached bioactivity data

sub processData : Private {
    my ( $self, $c ) = @_;

    # Create SQL filter
    $c->forward('createSqlBioFilter');

    # Get search job_id
    $c->stash->{jobid} = $c->model('SARfariDB::Dual')->getJobid;

    # Load bio search details
    $c->model("SARfariDB::AppBioSearchJobs")->create(
        {   job_id     => $c->stash->{jobid},
            session_id => $c->sessionid,
            username   => $c->session->{username},
            query_type => $c->stash->{searchType}
        }
    );

    # Load data if present
    $c->forward( 'loadData', ['target'] ),
        if ( $c->stash->{data}->{target} );

    $c->forward( 'loadData', ['compound'] ),
        if ( $c->stash->{data}->{compound} );

    # If this is an advanced search branch off to intermediate page
    if ( $c->req->params->{advanced} ) {
        $c->detach('subQuery');
    }

    # Load bioactivity data into cache
    $c->model('SARfariDB::Dual')->bioSearch(
        $c->stash->{jobid},
        $self->dbhQuote( $c, $c->stash->{searchType} ),
        $self->dbhQuote( $c, $c->stash->{bioFilters} )
    );

    $c->res->redirect(
        $c->uri_for(
                  "/bioactivity/results/"
                . $c->stash->{jobid}
                . "/1/display_name/asc"
        )
    );

    $c->detach();
}

# Process and load cached bioactivity data

sub advanced : Local {
    my ( $self, $c ) = @_;

    # Get search job_id
    $c->stash->{jobid}      = $c->req->params->{'jobid'};
    $c->stash->{searchType} = 'target';

    # Create SQL filter
    if ( $c->req->params->{bioQueryType} eq 'bio' ) {

        # Create bioactivity filter, creates single where clause
        $c->forward('createSqlBioFilter');

        # Clear previous bio search results - keep job id as
        $c->model('SARfariDB::Dual')->removeBioData( $c->stash->{jobid} );

        # Load bioactivity data into cache
        $c->model('SARfariDB::Dual')->bioSearch(
            $c->stash->{jobid},
            $self->dbhQuote( $c, $c->stash->{searchType} ),
            $self->dbhQuote( $c, $c->stash->{bioFilters} )
        );

        $c->res->redirect(
            $c->uri_for(
                      "/bioactivity/results/"
                    . $c->stash->{jobid}
                    . "/1/display_name/asc"
            )
        );

        $c->detach();
    }
    elsif ( $c->req->params->{bioQueryType} eq 'cross' ) {

        # Create bioactivity filter, creates single where clause
        $c->forward('createSqlBioFilter');

        # Clear previous bio search results - keep job id as
        $c->model('SARfariDB::Dual')->removeBioData( $c->stash->{jobid} );

        # Load bioactivity data into cache
        $c->model('SARfariDB::Dual')->bioSearch(
            $c->stash->{jobid},
            $self->dbhQuote( $c, $c->stash->{searchType} ),
            $self->dbhQuote( $c, $c->stash->{bioFilters} )
        );

        $c->res->redirect(
            $c->uri_for(
                "/bioactivity/crossreactivity/" . $c->stash->{jobid}
            )
        );

        $c->detach();
    }

    # Create SQL filter
    elsif ( $c->req->params->{bioQueryType} eq 'comp' ) {

        # Create filter sets - this is different from bioactivity
        $c->forward('createSqlCompFilter');

        my $ID_STORE     = {};
        my $FINAL_ID_SET = {};
				
        # Check compound filters have been created
        if ( $c->stash->{compFilters}
            && scalar( @{ $c->stash->{compFilters} } ) > 0 ) {
					
            # Don't do unions
            # 1. get each set of sarregnos
            # 2. Then forward to compound load

            my $filter_counter = 0;

            foreach my $sub_filter ( @{ $c->stash->{compFilters} } ) {

                $filter_counter++;
                
                # Get compound registration numbers
                my $regno_list =
                    $c->model("SARfariDB::AppSearchTargetCache")
                    ->get_compounds( $c->stash->{jobid}, $sub_filter );

				# Each time we go through clear final id set
                $FINAL_ID_SET = {};

                foreach my $regno ( @{$regno_list} ) {

                    # Prepopulate $ID_STORE on first pass
                    $ID_STORE->{$regno} = 1, if ( $filter_counter == 1 );
										
                    $FINAL_ID_SET->{$regno} = 1, if ( $ID_STORE->{$regno} );                                        
                }
                
                # Set Id 
                $ID_STORE = $FINAL_ID_SET;
                
            }

        }
        else {
		
            # Just get all compounds associated with jobid
            # Then forward to compound view
            my $regno_list =
                $c->model("SARfariDB::AppSearchTargetCache")
                ->get_compounds( $c->stash->{jobid} );

            foreach my $regno ( @{$regno_list} ) {
                $FINAL_ID_SET->{$regno} = 1;
            }
        }

        # $FINAL_ID_SET contains id list need to set up compound
        # search defaults

        my $regno_string = join( "\n", keys %{$FINAL_ID_SET} );
        		
		# If no data retured give pseudo '-1' registration code, prevents 
		# exceptions in Search.pm
        $c->req->params->{'compoundList'} = $regno_string || -1;
        $c->req->params->{'compoundType'} = "regno";

        # Go to compound search
        $c->detach("/compound/search");
    }
    else {
        Catalyst::Exception->throw(
            "Bioactivity query type has not been defined");
    }
}

# Private method for displaying paged bioactivity data

sub crossreactivity : LocalRegex('crossreactivity/(\d+)$') {
    my ( $self, $c ) = @_;

    my ($jobid) = @{ $c->request->snippets };

    # Needed for cross reactivity file generation
    $c->stash->{jobid} = $jobid;

    # Create bioactivity filter, creates single where clause
    $c->forward('runCrossReactivity');

    # View Results
    $c->stash->{body} = "bioactivity/bio_crossreactivity.tt";
}

# Create and write cross reactivity data

sub runCrossReactivity : Private {
    my ( $self, $c ) = @_;

    my $selected_cols = [
        'me.dom_id',             'me.sarregno',
        'classification.level2', 'classification.level3',
        'classification.level4', 'domain.display_name',
        'dictionary.synonyms',   'dictionary.candistore',
        'dictionary.starlite',   'dictionary.drugstore'
    ];

    # Get bioactivity data, plus some extras
    my $cross_rs = [
        $c->model("SARfariDB::AppBioSearchCache")->search(
            'me.job_id' => $c->stash->{jobid},
            {   select => $selected_cols,
                join   => [
                    { domain => [ { 'gene_domain' => 'classification' } ] },
                    'dictionary'
                ]
            }
            )->cursor->all
    ];

    # Make initial data structure
    my $data = {};
    foreach my $row ( @{$cross_rs} ) {

        #while ( my $q = $c->stash->{cross_rs}->next ) {

        my $dom_id       = $row->[0];
        my $sarregno     = $row->[1];
        my $level2       = $row->[2];
        my $level3       = $row->[3];
        my $level4       = $row->[4];
        my $display_name = $row->[5];
        my $synonyms     = $row->[6];
        my $candistore   = $row->[7];
        my $starlite     = $row->[8];
        my $drugstore    = $row->[9];

        # Add sarregno up-to dom_id classification
        push(
            @{  $data->{domid}->{
                    join( '__',
                        ( $level2, $level3, $level4, $display_name, $dom_id )
                    )
                    }
                },
            $sarregno
        );

        # Capture compound details
        if ( !$c->stash->{comp_details}->{$sarregno} ) {
            $c->stash->{comp_details}->{$sarregno} = {
                'synonyms'   => default_value($synonyms),
                'candistore' => default_value($candistore),
                'starlite'   => default_value($starlite),
                'drugstore'  => default_value($drugstore)
            };
        }
    }    
    # Get unique sets of compounds foreach classification level
    my $newdata = {};

    for my $key1 ( keys %{$data} ) {
        for my $key2 ( keys %{ $data->{$key1} } ) {
            $newdata->{$key1}->{$key2} =
                [ uniq @{ $data->{$key1}->{$key2} } ];
            delete $data->{$key1}->{$key2};    # free up some memory
        }
    }

    # Calculate compounds shared between domains
    $c->stash->{compshare} =
        $c->forward( 'calculateSharedComps', [ $newdata->{domid} ] );

    # Write file
    $c->stash->{results_file} = $c->forward('createCrossReactivityFile');

}

# Create CrossReactivity File

sub createCrossReactivityFile : Private {
    my ( $self, $c ) = @_;

    my $fid     = int( rand(1000000) );
    my $file    = "cross_reactivity_result\_$fid.txt";
    my $tmpfile = new IO::File "> " . $c->config->{tmpdir} . "/$file";

    my @file_header =
        qw/LEVEL2_1 LEVEL3_1 LEVEL4_1 NAME_1 DOM_ID_1 LONG_NAME_1
        LEVEL2_2 LEVEL3_2 LEVEL4_2 NAME_2 DOM_ID_2 LONG_NAME_2
        COUNT SARREGNO CHEMBL DRUGSTORE CANDISTORE SYNONYMS/;

    print $tmpfile join( "\t", @file_header ) . "\n";

    foreach my $r1 ( keys %{ $c->stash->{compshare} } ) {
        foreach my $r2 ( keys %{ $c->stash->{compshare}->{$r1} } ) {
            my ( $l2_1, $l3_1, $l4_1, $name_1, $domid_1 ) =
                split( /__/, $r1 );
            my ( $l2_2, $l3_2, $l4_2, $name_2, $domid_2 ) =
                split( /__/, $r2 );

            foreach my $sarregno (
                @{ $c->stash->{compshare}->{$r1}->{$r2}->{shared} } ) {

                my $count =
                    ( $c->stash->{compshare}->{$r1}->{$r2}->{count} )
                    ? $c->stash->{compshare}->{$r1}->{$r2}->{count}
                    : 0;

                print $tmpfile $l2_1 . "\t"
                    . default_value($l3_1) . "\t"
                    . default_value($l4_1) . "\t"
                    . $name_1 . "\t"
                    . $domid_1 . "\t"
                    . $r1 . "\t"
                    . $l2_2 . "\t"
                    . default_value($l3_2) . "\t"
                    . default_value($l4_2) . "\t"
                    . $name_2 . "\t"
                    . $domid_2 . "\t"
                    . $r2 . "\t"
                    . $count . "\t"
                    . $sarregno . "\t"
                    . $c->stash->{comp_details}->{$sarregno}->{starlite}
                    . "\t"
                    . $c->stash->{comp_details}->{$sarregno}->{drugstore}
                    . "\t"
                    . $c->stash->{comp_details}->{$sarregno}->{candistore}
                    . "\t"
                    . $c->stash->{comp_details}->{$sarregno}->{synonyms}
                    . "\n";
            }
        }
    }
    $tmpfile->close;

    return $file;
}

# Return a default value

sub default_value {
    my $value = shift;
    return ( !$value ) ? "-" : $value;
}

# Download a tmp file

sub download : Regex('^download_text/(.*?)$') {
    my ( $self, $c ) = @_;

    my $filename = $c->req->captures->[0];
    my $path     = $c->config->{tmpdir} . "/" . $filename;
    my $fh       = new IO::File $path, "r";
    my $content  = do { local $/; <$fh> };

    $c->res->header( 'Content-Disposition',
        qq[attachment; filename="$filename"] );
    $c->res->content_type('text/plain');
    $c->res->body($content);
}

sub createREG : Private {
    my ( $self, $c, $jobid ) = @_;

    # Used to get query type at last minute, as default sort is different for
    # similarity search
    my $job_detials = $c->model('SARfariDB::AppBioSearchJobs')->find($jobid);

    # Check data is associated with supplied job
    if ( !$job_detials ) {
        Catalyst::Exception->throw(
            "Job id: $jobid, is not associated with any data");
    }

    # Check to see if bio dat has not already been loaded
    # ! If check not carried out unique constraint on bio jobs table
    # ! may be broken
    my $regnos =
        $c->model('SARfariDB::AppBioSearchCache')->get_job_column_data($jobid, 'sarregno');
    
    my $regno_string = join( "\n", @{$regnos});
    
    # If no data retured give pseudo '-1' registration code, prevents 
	# exceptions in Search.pm
    $c->req->params->{'compoundList'} = $regno_string || -1;
    $c->req->params->{'compoundType'} = "regno";

    # Go to compound search
    $c->detach("/compound/search");
}

sub createDOM : Private {
    my ( $self, $c, $jobid ) = @_;

    # Used to get query type at last minute, as default sort is different for
    # similarity search
    my $job_detials = $c->model('SARfariDB::AppBioSearchJobs')->find($jobid);

    # Check data is associated with supplied job
    if ( !$job_detials ) {
        Catalyst::Exception->throw(
            "Job id: $jobid, is not associated with any data");
    }

    # Check to see if bio dat has not already been loaded
    # ! If check not carried out unique constraint on bio jobs table
    # ! may be broken
    my $domids =
        $c->model('SARfariDB::AppBioSearchCache')->get_job_column_data($jobid, 'dom_id');
    
    my $domain_string = join( "\n", @{$domids});
    
    # If no data retured give pseudo '-1' registration code, prevents 
	# exceptions in Search.pm
    $c->req->params->{'targetList'} = $domain_string || -1;
    $c->req->params->{'targetType'} = "domid";

    # Go to compound search
    $c->detach("/protein/search");
}

# Calculate counts of compounds shared between domains

sub calculateSharedComps : Private {
    my ( $self, $c, $dataref ) = @_;
    my $results = {};

    for my $targetA ( sort { $a cmp $b } keys %{$dataref} ) {

        for my $targetB ( sort { $a cmp $b } keys %{$dataref} ) {

            # May already of been calculated

            next, if ( $results->{$targetA}->{$targetB} );

            # When target a and b are the same
            if ( $targetA eq $targetB ) {
                $results->{$targetA}->{$targetB}->{count} =
                    scalar( @{ $dataref->{$targetA} } );
                $results->{$targetA}->{$targetB}->{shared} =
                    $dataref->{$targetA};
                $results->{$targetB}->{$targetA}->{count} =
                    scalar( @{ $dataref->{$targetA} } );
                $results->{$targetB}->{$targetA}->{shared} =
                    $dataref->{$targetA};
                next;
            }
            else {
                my $match  = 0;
                my $shared = [];
                for ( my $i = 0; $i < @{ $dataref->{$targetA} }; $i++ ) {
                    for ( my $j = 0; $j < @{ $dataref->{$targetB} }; $j++ ) {

                        # Shared compound identified
                        if (scalar( $dataref->{$targetA}[$i] ) ==
                            scalar( $dataref->{$targetB}[$j] ) ) {
                            $match++;
                            push( @{$shared}, $dataref->{$targetA}[$i] );
                        }
                    }
                }

                # Match both ways to get full matrix
                $results->{$targetA}->{$targetB}->{count}  = $match;
                $results->{$targetA}->{$targetB}->{shared} = $shared;
                $results->{$targetB}->{$targetA}->{count}  = $match;
                $results->{$targetB}->{$targetA}->{shared} = $shared;
            }
        }
    }
    return $results;
}


# Private method for displaying paged bioactivity data

sub results : LocalRegex('results/(\d+)/(\d+)/(\w+)/(\w+)$') {
    my ( $self, $c ) = @_;

    my ( $jobid, $page, $sorted_on, $sort_way ) = @{ $c->request->snippets };

    $c->stash->{jobid}     = $jobid;
    $c->stash->{sorted_on} = $sorted_on;
    $c->stash->{sort_way}  = $sort_way;
    $c->stash->{page}      = $page;

    my $DEFAULT_PAGE_SIZE = 200;

    # Get Paged results
    $c->stash->{bio_details} =
        $c->model("SARfariDB::AppBioSearchCache")->search(
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
    $c->stash->{bio_search_details} =
        $c->model('SARfariDB::AppBioSearchJobs')->find( $c->stash->{jobid} );

    # Get paging information
    $c->stash->{pager} = $c->stash->{bio_details}->pager;

    # View Results
    $c->stash->{body} = "bioactivity/bio_search_results.tt";
}

# Creates advanced bioactivity menu system

sub subQuery : Private {
    my ( $self, $c ) = @_;

    my $DRY = {};

    # Check that search has returned domain id's
    if ( $c->stash->{data}->{target} ) {

        # Can only get target data at this stage
        foreach my $batch ( @{ $c->stash->{data}->{target} } ) {

            my $data = [
                $c->model('SARfariDB::AppActivitiesToDomains')->search(
                    {   'me.dom_id'     => $batch,
                        'me.assay_type' => 'B'
                    },
                    {   select => [
                            qw/ me.dom_id       me.source
                                me.display_name me.activity_type /
                        ]
                    }
                    )->cursor->all
            ];

            for my $row ( @{$data} ) {

                #'All' details are represented by ksdid -1
                if ( !$DRY->{'All'}->{'dom_id'} ) {
                    $DRY->{'All'}->{'dom_id'} = -1;
                }

                my $dom_id        = $row->[0];
                my $display_name  = $row->[2];
                my $method        = "Not Specified";
                my $test_uid      = "Not Specified";
                my $activity_type = add_units( $row->[3] );

                $DRY->{$display_name}->{'dom_id'} = $dom_id;

                if ( !$DRY->{$display_name}->{'activity_type'}
                    ->{$activity_type}->{$method} ) {
                    $DRY->{$display_name}->{'activity_type'}->{$activity_type}
                        ->{$method} = $test_uid;
                }

                if ( !$DRY->{'All'}->{'activity_type'}->{$activity_type}
                    ->{$method} ) {
                    $DRY->{'All'}->{'activity_type'}->{$activity_type}
                        ->{$method} = $test_uid;
                }
            }
        }
    }

    $c->stash->{advanced_data} = $DRY;

    if ( !scalar( keys %{ $c->stash->{advanced_data} } ) ) {
        $c->detach( '/error/index',
            ["The bioactivity query has returned 0 results"] );
    }

    # View Results
    $c->stash->{body} = "bioactivity/bio_search_advanced.tt";

}

# Regex used to direct user to report card bioactivity results

sub report : LocalRegex('report/(\w+)/(\w+)/(\w)/(\d+)/(\w+)$') {
    my ( $self, $c ) = @_;

    my ( $report_type, $db_source, $assay_type, $id, $activity_type ) =
        @{ $c->request->snippets };

    # Set up pseudo body parameters
    $c->req->params->{ $report_type . 'Type' } =
        ( lc($report_type) eq "compound" ) ? "regno" : "domid";
    $c->req->params->{ $report_type . 'List' }     = $id;
    $c->req->params->{ "assayType" . $assay_type } = $assay_type;
    $c->req->params->{'databaseSource'}            = $db_source;
    $c->req->params->{'filterChk5'}                = 1;
    $c->req->params->{'filterOp5'}                 = "NA";
    $c->req->params->{'filterAct5'}                =
        ( $activity_type eq "thalf" ) ? "T1/2" : $activity_type;

    $c->detach("search");
}

# Display bioactivity details (source dependent view)

sub details : LocalRegex('details/(\w+)/(\d+)$') {

    my ( $self, $c ) = @_;

    my ( $db_source, $activity_id ) = @{ $c->request->snippets };

    if ( ( uc($db_source) eq 'CHEMBL' )||( uc($db_source) eq 'STARLITE' ) ){
        $c->stash->{bio_details} = [
            $c->model('SARfariDB::StarliteActivities')->search(
                'me.activity_id' => $activity_id,
                { prefetch => [ { 'batch' => ['star_doc'] }, 'star_assay' ] }
                )->all
        ];
    }
    else {
        Catalyst::Exception->throw(
            "Details database ($db_source), not recognised");
    }

	$c->stash->{simple} = 1;
    $c->stash->{body}   =
        "bioactivity/bio_" . lc($db_source) . "_details.tt";
}

# Create bioactivity filter

sub createSqlBioFilter : Private {
    my ( $self, $c ) = @_;

    my @filters;

    for ( my $i = 1; $i <= $c->config->{bio_filter_count}; $i++ ) {

        # Test if filter has been checked
        if ( $c->req->params->{ 'filterChk' . $i } ) {

            my $sql = createSql(
                $c->req->params->{ 'filterAct' . $i },
                $c->req->params->{ 'filterOp' . $i },
                $c->req->params->{ 'filterVal' . $i }
            );

            # Dom_is may be included in filter
            if (   $c->req->params->{ 'filterDom' . $i }
                && $c->req->params->{ 'filterDom' . $i } > 0 ) {

                # ! Note, c1 is table alias in bio_search procedure
                my $domid_filter =
                    " c1.DOM_ID = " . $c->req->params->{ 'filterDom' . $i };
                my $tmpsql =
                    ($sql) ? "$domid_filter AND $sql" : $domid_filter;
                $sql = $tmpsql;
            }

            # create_sql_filter_simple returns undef if it has not created
            # a statement
            if ($sql) {
                push( @filters, $sql );
            }
        }
    }

    # If filters have been created join with ' OR ' and add brackets
    $c->stash->{bioFilters} =
        ( scalar(@filters) > 0 )
        ? ' ( ' . join( ' OR ', @filters ) . ' ) '
        : undef;

    # If assayType has been specified in query add to filter
    if (   $c->req->params->{'assayTypeA'}
        && $c->req->params->{'assayTypeB'}
        && $c->req->params->{'assayTypeF'} ) {

        # No need to add filter just select everthing

    }
    elsif ($c->req->params->{'assayTypeA'}
        || $c->req->params->{'assayTypeB'}
        || $c->req->params->{'assayTypeF'} ) {

        my @assayTypeFilter;

        if ( $c->req->params->{'assayTypeA'} ) {
            push( @assayTypeFilter, " ( upper(ASSAY_TYPE) = 'A' ) " );
        }

        if ( $c->req->params->{'assayTypeB'} ) {
            push( @assayTypeFilter, " ( upper(ASSAY_TYPE) = 'B' ) " );
        }

        if ( $c->req->params->{'assayTypeF'} ) {
            push( @assayTypeFilter, " ( upper(ASSAY_TYPE) = 'F' ) " );
        }

        # May require AND if bioFilters already defined
        my $and = ( $c->stash->{bioFilters} ) ? " AND " : " ";

        $c->stash->{bioFilters} .=
            " $and ( " . join( " OR ", @assayTypeFilter ) . ")";
    }
    else {

# If no assay type is defined
#$c->detach(
#    '/error/index',
#    [   "The bioactivity query has returned 0 results (No assay type selected!)"
#    ]
#);
    }

    # If assayType has been specified in query add to filter
    if (   $c->req->params->{'databaseSource'}
        && ($c->req->params->{'databaseSource'} =~ qr/\A chembl \z/xmis)
    )
    {

        # May require AND if bioFilters already defined
        my $and = ( $c->stash->{bioFilters} ) ? " AND " : " ";

        $c->stash->{bioFilters} .=
            " $and ( upper(SOURCE) = '"
            . uc( $c->req->params->{'databaseSource'} ) . "' )";
    }

}

# Create bioactivity filter, but will ultimately return compound data

sub createSqlCompFilter : Private {
    my ( $self, $c ) = @_;

    my $sql = "";

    for ( my $i = $c->config->{bio_filter_count}; $i > 0; $i-- ) {

        # Test if filter has been checked
        if ( $c->req->params->{ 'filterChk' . $i } ) {

            my $biosql = createSql(
                $c->req->params->{ 'filterAct' . $i },
                $c->req->params->{ 'filterOp' . $i },
                $c->req->params->{ 'filterVal' . $i }
            );

            # Dom_id may be included in filter
            my $domid_filter = "";

            # ! Note -1 dom_id = all, no restriction needed
            if (   $c->req->params->{ 'filterDom' . $i }
                && $c->req->params->{ 'filterDom' . $i } > 0 ) {

                # ! Note, me is table alias
                $domid_filter =
                    " me.DOM_ID = " . $c->req->params->{ 'filterDom' . $i };
                $domid_filter .= " AND ", if ($biosql);
            }

            $sql .=
                  $domid_filter . " " . $biosql . " "
                . $c->req->params->{ 'filterAndOr' . $i } . " ";

        }
    }

    # Clean trailing and/or
    $sql =~ s{ (USER_AND|OR|NA) \s+ \z}{}xmis;

    # Split SQL based on user ands - creates seperate queries
    my @filters = split( /USER_AND/, $sql );

    # Add possible extras to each seperate query
    foreach my $filter (@filters) {

        # If assayType has been specified in query add to filter
        if (   $c->req->params->{'assayTypeA'}
            && $c->req->params->{'assayTypeB'}
            && $c->req->params->{'assayTypeF'} ) {

            # No need to add filter just select everthing

        }
        elsif ($c->req->params->{'assayTypeA'}
            || $c->req->params->{'assayTypeB'}
            || $c->req->params->{'assayTypeF'} ) {

            my @assayTypeFilter;

            if ( $c->req->params->{'assayTypeA'} ) {
                push( @assayTypeFilter, " ( upper(ASSAY_TYPE) = 'A' ) " );
            }

            if ( $c->req->params->{'assayTypeB'} ) {
                push( @assayTypeFilter, " ( upper(ASSAY_TYPE) = 'B' ) " );
            }

            if ( $c->req->params->{'assayTypeF'} ) {
                push( @assayTypeFilter, " ( upper(ASSAY_TYPE) = 'F' ) " );
            }

            $filter .= " AND ( " . join( " OR ", @assayTypeFilter ) . ")";
        }
        else {

            # No need to add filter just select everthing

        }

        # If assayType has been specified in query add to filter
        if (   $c->req->params->{'databaseSource'}
            && ($c->req->params->{'databaseSource'} =~ qr/\A chembl \z/xmis)
        )
        {

            $filter .=
                " AND ( upper(SOURCE) = '"
                . uc( $c->req->params->{'databaseSource'} ) . "' )";
        }

        push( @{ $c->stash->{compFilters} }, $filter );
    }

}

# Create sql used in bioactivity filter

sub createSql {
    my ( $act, $op, $val ) = @_;

    #Remove units
    $act =~ s/\s+\(.*?\)$//, if ($act);

    # If type (IC50, KI etc),  is ' All ' implies no filter
    if ( $act eq "All" ) {
        return undef;
    }

    # Complete query
    if ( $act && $op && $val ) {
        return " (
        upper(ACTIVITY_TYPE) = '"
            . uc($act) . "' AND STANDARD_VALUE $op $val) ";
    }

    # Restricts results to type
    if ( $act && $op eq "NA" ) {
        return " (upper(ACTIVITY_TYPE)='" . uc($act) . "') ";
    }

    # If value missing can not make query
    if ( $act && !$val ) {
        return " (upper(ACTIVITY_TYPE)='" . uc($act) . "') ";
    }

    # Otherwise no sql
    return undef;
}

# Priavte method for creating compound txt download

sub createTXT : Private {
    my ( $self, $c, $jobid ) = @_;

    # Set up download with header information
    my $download = join( "\t",
        $c->model('SARfariDB::AppBioSearchCache')->result_source->columns )
        . "\n";

    # Local block used to contain warning switch off as nulls can be returned
    # from db query
    {
        no warnings 'uninitialized';

        $download .= join( "\n",
            map { join( "\t", @{$_} ) }
                $c->model("SARfariDB::AppBioSearchCache")
                ->search( 'me.job_id' => $jobid )->cursor->all );
    }

    my $filename = "bio_download\_$jobid.txt";

    $c->res->header( 'Content-Disposition',
        qq[attachment; filename="$filename"] );
    $c->res->content_type('text/plain');
    $c->res->body($download);
}

# Default units used in refined TargetSearch drop-down menus
# This needs cleaning up

sub add_units {
    my $type = shift;
    $type =~ s/^\s+//g;
    $type =~ s/\s+$//g;

    #Return type + standard unit
    if ( $type eq "IC50" ) {
        return "IC50 (nM)";
    }
    elsif ( $type eq "Inhibition" ) {
        return "Inhibition (%)";
    }
    elsif ( $type eq "Kd" ) {
        return "Kd (nM)";
    }
    elsif ( $type eq "Ki" ) {
        return "Ki (nM)";
    }
    elsif ( $type eq "Activity" ) {
        return "Activity (%)";
    }
    elsif ( $type eq "ED50" ) {
        return "ED50 (nM)";
    }
    elsif ( $type eq "EC50" ) {
        return "EC50 (nM)";
    }
    elsif ( $type eq "GI50" ) {
        return "GI50 (nM)";
    }
    elsif ( $type eq "MIC" ) {
        return "MIC (nM)";
    }
    elsif ( $type eq "Control" ) {
        return "Control (%)";
    }
    else {
        return $type;
    }
}

1;

