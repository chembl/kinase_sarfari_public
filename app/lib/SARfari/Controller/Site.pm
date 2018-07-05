package SARfari::Controller::Site;
# $Id: Site.pm 602 2010-04-12 09:50:59Z sarfari $

# SEE LICENSE

use strict;
use warnings;
use base 'SARfari::BaseController::Search';
use Data::Dumper;
use Storable;
use Scalar::Util qw (reftype);

sub auto : Private {
    my ( $self, $c ) = @_;

    $c->stash->{subtitle} = "Binding Site";
}

sub index : Private {
    my ( $self, $c ) = @_;

    $c->stash->{body} = "site/site_home.tt";
}

sub pairwise : LocalRegex('pairwise/(\d+)/(\d+)/(\w+)$') {
    my ( $self, $c ) = @_;

    my ( $site, $dom_id, $type ) = @{ $c->request->snippets };

    # Must send site, default to canonical site (site 3)
    my $params = {
        dom_id => $dom_id,
        type   => $type,
        site   => $site,
    };

    # If user selected domains provided
    if($type eq "mat" && $c->req->params->{'selectedDomids'}){

        my $tmp_aref =
            ( reftype $c->req->params->{'selectedDomids'} eq "ARRAY" )
            ? $c->req->params->{'selectedDomids'}
            : [ $c->req->params->{'selectedDomids'} ];    
        
        foreach my $mat_id (@{$tmp_aref}){
            $params->{matrix_ids}->{$mat_id} = 1;
        }
    }

    my $dom_dis = $c->model('SARfariDB::SiteDomainDistance')->search(
        {   'me.site'   => $params->{site},
            'me.dom_id' => $params->{dom_id},
        }
    )->first;

    my $data =
        $c->forward( 'sortDistances', [ $dom_dis->distances, $params ] );

    # Turn into hash, ordering does not matter
    $c->stash->{data}->{pairwise_scores} =
        { map { [ keys %{$_} ]->[0] => [ values %{$_} ]->[0] } @{$data} };

    # Get domids for batchifying, ordering does not matter
    my $ordered_domids = [ keys %{ $c->stash->{data}->{pairwise_scores} } ];

    $c->stash->{data}->{target} =
        $c->forward( 'createBatches', [$ordered_domids] );

    # Get protein target data
    if ( $c->stash->{data}->{target} ) {
        foreach my $batch ( @{ $c->stash->{data}->{target} } ) {
            push(
                @{ $c->stash->{target_details} },
                grep {$_} @{
                    $c->model('SARfariDB::ProtDomain')
                        ->getProtDetails( $batch, $params )
                    }
            );
        }
    }

    # Get site specific details
    $c->stash->{query_details} =
        $c->model('SARfariDB::ProtDomain')->find($dom_id);

    # Used in template
    $c->stash->{site} = $site;

    # View Results
    $c->stash->{body} = "site/site_pairwise_results.tt";
}

sub align : LocalRegex('align/(\d+)/(\d+)/(\d+)$') {
    my ( $self, $c ) = @_;

    my ( $site, $query, $target ) = @{ $c->request->snippets };

    my $params = {
        query  => $query,
        target => $target,
        site   => $site,
    };

    $c->stash->{site_aln} =
        $c->model('SARfariDB::SiteDefinitions')->getSiteAlign($params);

    # Add distance score - requires residue sub matrix
    # Historically this data was encrypted in a file - quick fix move data structure straight into file
	my $mat = {
        'F' => {'F' => '0.000','S' => '2.167','T' => '1.872','N' => '1.877','K' => '1.834','E' => '1.850','Y' => '0.666','V' => '1.003','-' => '1.400','Q' => '1.928','M' => '0.739','C' => '1.142','L' => '0.691','A' => '1.642','W' => '0.736','P' => '1.452','H' => '1.313','D' => '2.05
0','R' => '2.435','I' => '1.034','G' => '2.498'},
        'S' => {'F' => '2.167','S' => '0.000','T' => '0.457','N' => '0.436','K' => '1.788','E' => '1.033','Y' => '1.907','V' => '1.257','-' => '1.400','Q' => '0.590','M' => '1.689','C' => '1.272','L' => '1.530','A' => '1.015','W' => '2.812','P' => '1.485','H' => '1.545','D' => '1.05
9','R' => '2.077','I' => '1.767','G' => '0.465'},
        'T' => {'F' => '1.872','S' => '0.457','T' => '0.000','N' => '0.210','K' => '1.631','E' => '1.033','Y' => '1.688','V' => '1.026','-' => '1.400','Q' => '0.459','M' => '1.325','C' => '1.007','L' => '1.263','A' => '0.783','W' => '2.528','P' => '1.501','H' => '1.140','D' => '1.15
2','R' => '1.963','I' => '1.678','G' => '0.882'},
        'N' => {'F' => '1.877','S' => '0.436','T' => '0.210','N' => '0.000','K' => '1.721','E' => '0.844','Y' => '1.649','V' => '1.074','-' => '1.400','Q' => '0.314','M' => '1.369','C' => '1.052','L' => '1.297','A' => '0.924','W' => '2.523','P' => '1.497','H' => '1.261','D' => '0.97
5','R' => '2.031','I' => '1.663','G' => '0.898'},
        'K' => {'F' => '1.834','S' => '1.788','T' => '1.631','N' => '1.721','K' => '0.000','E' => '2.254','Y' => '1.548','V' => '1.421','-' => '1.400','Q' => '1.662','M' => '1.759','C' => '1.812','L' => '1.435','A' => '1.736','W' => '2.131','P' => '1.367','H' => '1.193','D' => '2.44
6','R' => '0.738','I' => '1.492','G' => '1.964'},
        'E' => {'F' => '1.850','S' => '1.033','T' => '1.033','N' => '0.844','K' => '2.254','E' => '0.000','Y' => '1.568','V' => '1.318','-' => '1.400','Q' => '0.858','M' => '1.535','C' => '1.235','L' => '1.457','A' => '1.436','W' => '2.443','P' => '1.582','H' => '1.811','D' => '0.30
2','R' => '2.589','I' => '1.632','G' => '1.374'},
        'Y' => {'F' => '0.666','S' => '1.907','T' => '1.688','N' => '1.649','K' => '1.548','E' => '1.568','Y' => '0.000','V' => '0.984','-' => '1.400','Q' => '1.612','M' => '1.051','C' => '1.270','L' => '0.751','A' => '1.706','W' => '0.991','P' => '1.107','H' => '1.368','D' => '1.79
4','R' => '2.062','I' => '0.719','G' => '2.236'},
        'V' => {'F' => '1.003','S' => '1.257','T' => '1.026','N' => '1.074','K' => '1.421','E' => '1.318','Y' => '0.984','V' => '0.000','-' => '1.400','Q' => '1.217','M' => '0.682','C' => '0.451','L' => '0.320','A' => '0.750','W' => '1.682','P' => '0.899','H' => '0.944','D' => '1.45
9','R' => '2.046','I' => '0.856','G' => '1.532'},
        '-' => {'F' => '1.400','S' => '1.400','T' => '1.400','N' => '1.400','K' => '1.400','E' => '1.400','Y' => '1.400','V' => '1.400','-' => '0.000','Q' => '1.400','M' => '1.400','C' => '1.400','L' => '1.400','A' => '1.400','W' => '1.400','P' => '1.400','H' => '1.400','D' => '1.40
0','R' => '1.400','I' => '1.400','G' => '1.400'},
        'Q' => {'F' => '1.928','S' => '0.590','T' => '0.459','N' => '0.314','K' => '1.662','E' => '0.858','Y' => '1.612','V' => '1.217','-' => '1.400','Q' => '0.000','M' => '1.494','C' => '1.267','L' => '1.396','A' => '1.200','W' => '2.518','P' => '1.537','H' => '1.323','D' => '1.04
0','R' => '1.883','I' => '1.693','G' => '1.035'},
        'M' => {'F' => '0.739','S' => '1.689','T' => '1.325','N' => '1.369','K' => '1.759','E' => '1.535','Y' => '1.051','V' => '0.682','-' => '1.400','Q' => '1.494','M' => '0.000','C' => '0.603','L' => '0.536','A' => '1.038','W' => '1.439','P' => '1.514','H' => '0.846','D' => '1.72
2','R' => '2.338','I' => '1.293','G' => '2.045'},
        'C' => {'F' => '1.142','S' => '1.272','T' => '1.007','N' => '1.052','K' => '1.812','E' => '1.235','Y' => '1.270','V' => '0.451','-' => '1.400','Q' => '1.267','M' => '0.603','C' => '0.000','L' => '0.614','A' => '0.590','W' => '1.874','P' => '1.277','H' => '1.072','D' => '1.34
0','R' => '2.404','I' => '1.222','G' => '1.563'},
        'L' => {'F' => '0.691','S' => '1.530','T' => '1.263','N' => '1.297','K' => '1.435','E' => '1.457','Y' => '0.751','V' => '0.320','-' => '1.400','Q' => '1.396','M' => '0.536','C' => '0.614','L' => '0.000','A' => '1.018','W' => '1.366','P' => '0.991','H' => '0.928','D' => '1.63
1','R' => '2.070','I' => '0.783','G' => '1.832'},
        'A' => {'F' => '1.642','S' => '1.015','T' => '0.783','N' => '0.924','K' => '1.736','E' => '1.436','Y' => '1.706','V' => '0.750','-' => '1.400','Q' => '1.200','M' => '1.038','C' => '0.590','L' => '1.018','A' => '0.000','W' => '2.354','P' => '1.438','H' => '1.068','D' => '1.49
5','R' => '2.279','I' => '1.558','G' => '1.223'},
        'W' => {'F' => '0.736','S' => '2.812','T' => '2.528','N' => '2.523','K' => '2.131','E' => '2.443','Y' => '0.991','V' => '1.682','-' => '1.400','Q' => '2.518','M' => '1.439','C' => '1.874','L' => '1.366','A' => '2.354','W' => '0.000','P' => '1.894','H' => '1.849','D' => '2.66
0','R' => '2.661','I' => '1.422','G' => '3.141'},
        'P' => {'F' => '1.452','S' => '1.485','T' => '1.501','N' => '1.497','K' => '1.367','E' => '1.582','Y' => '1.107','V' => '0.899','-' => '1.400','Q' => '1.537','M' => '1.514','C' => '1.277','L' => '0.991','A' => '1.438','W' => '1.894','P' => '0.000','H' => '1.627','D' => '1.67
2','R' => '1.949','I' => '0.496','G' => '1.594'},
        'H' => {'F' => '1.313','S' => '1.545','T' => '1.140','N' => '1.261','K' => '1.193','E' => '1.811','Y' => '1.368','V' => '0.944','-' => '1.400','Q' => '1.323','M' => '0.846','C' => '1.072','L' => '0.928','A' => '1.068','W' => '1.849','P' => '1.627','H' => '0.000','D' => '2.02
3','R' => '1.670','I' => '1.574','G' => '1.887'},
        'D' => {'F' => '2.050','S' => '1.059','T' => '1.152','N' => '0.975','K' => '2.446','E' => '0.302','Y' => '1.794','V' => '1.459','-' => '1.400','Q' => '1.040','M' => '1.722','C' => '1.340','L' => '1.631','A' => '1.495','W' => '2.660','P' => '1.672','H' => '2.023','D' => '0.00
0','R' => '2.793','I' => '1.765','G' => '1.318'},
        'R' => {'F' => '2.435','S' => '2.077','T' => '1.963','N' => '2.031','K' => '0.738','E' => '2.589','Y' => '2.062','V' => '2.046','-' => '1.400','Q' => '1.883','M' => '2.338','C' => '2.404','L' => '2.070','A' => '2.279','W' => '2.661','P' => '1.949','H' => '1.670','D' => '2.79
3','R' => '0.000','I' => '2.105','G' => '2.240'},
        'I' => {'F' => '1.034','S' => '1.767','T' => '1.678','N' => '1.663','K' => '1.492','E' => '1.632','Y' => '0.719','V' => '0.856','-' => '1.400','Q' => '1.693','M' => '1.293','C' => '1.222','L' => '0.783','A' => '1.558','W' => '1.422','P' => '0.496','H' => '1.574','D' => '1.76
5','R' => '2.105','I' => '0.000','G' => '1.964'},
        'G' => {'F' => '2.498','S' => '0.465','T' => '0.882','N' => '0.898','K' => '1.964','E' => '1.374','Y' => '2.236','V' => '1.532','-' => '1.400','Q' => '1.035','M' => '2.045','C' => '1.563','L' => '1.832','A' => '1.223','W' => '3.141','P' => '1.594','H' => '1.887','D' => '1.31
8','R' => '2.240','I' => '1.964','G' => '0.000'}
	};
	 
    foreach my $pos ( @{ $c->stash->{site_aln} } ) {
        $pos->{'distance'} = sprintf( "%.3f",
            $pos->{'weighting'} *
                $mat->{ $pos->{'residue'} }->{ $pos->{'residue2'} } );
    }

    # Get site specific details
    $c->stash->{site_details} =
        $c->model('SARfariDB::SiteName')->find( $params->{site} );

    # Get site specific details
    $c->stash->{features} =
        $c->model('SARfariDB::X3dFeaturePositions')->get_pos_features();
                    
    $c->stash->{simple}   = 1;
    $c->stash->{body} = "site/site_pairwise_aln.tt";
}

#

sub processData : Private {
    my ( $self, $c ) = @_;

    # Must send site, default to canonical site (site 3)
    my $params = {
        site  => $c->req->params->{'site'}  || 3,
        taxid => $c->req->params->{'taxid'} || undef
    };

    # Get protein target data
    if ( $c->stash->{data}->{target} ) {
        foreach my $batch ( @{ $c->stash->{data}->{target} } ) {
            push(
                @{ $c->stash->{target_details} },
                grep {$_} @{
                    $c->model('SARfariDB::ProtDomain')
                        ->getProtDetails( $batch, $params )
                    }
            );
        }
    }

    # Get site specific details
    $c->stash->{site_details} =
        $c->model('SARfariDB::SiteName')->find( $params->{site} );

    # View Results
    $c->stash->{body} = "site/site_search_results.tt";
}

# Parses/sorts domain distance column into something useful

sub sortDistances : Private {
    my ( $self, $c, $distances, $params ) = @_;

    my $distance = {};

    # Turns clob into array
    my @tmp = split( /\t/, $distances );

    # Parses distance data, format: "distance:dom_id"
    foreach my $t (@tmp) {
        $t =~ s/\s//g;
        my ( $dis, $dom_id ) = split( /:/, $t );
        next,
            if ( $params->{matrix_ids} && !$params->{matrix_ids}->{$dom_id} );
        $distance->{$dom_id} = $dis;
    }

    # This gets keys (dom_id) and sorts the $distance hashref based on
    # value pointed at by key Final map turns back to hash: dom_id => distance
    my $sort = [
        map {
            { $_ => $distance->{$_} }
            }
            sort { $distance->{$a} <=> $distance->{$b} }
            keys %{$distance}
    ];

    # If $c->stash->{nd_filter} != all
    if ( $params->{type} =~ /\d+/ ) {
        $sort = [ splice( @{$sort}, 0, $params->{type} ) ];
    }

    return $sort;
}

1;
