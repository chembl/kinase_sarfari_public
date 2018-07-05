package SARfari::Controller::Family;
# $Id: Family.pm 499 2010-01-13 21:44:05Z mdavies $

# SEE LICENSE

use strict;
use warnings;
use base 'SARfari::BaseController::Search';
use Data::Dumper;
use Scalar::Util qw (reftype);

sub auto : Private {
    my ( $self, $c ) = @_;
    $c->stash->{subtitle} = "Family";
}

sub index : Private {
    my ( $self, $c ) = @_;

    #delete $c->session->{user_selection};

    $c->stash->{body} = "family/family_home.tt";
}

sub userSelect : Local {
    my ( $self, $c ) = @_;

    if (   $c->req->params->{level2}
        && $c->req->params->{level3}
        && $c->req->params->{level4} ) {

        my $l2 = $c->req->params->{level2};
        my $l3 = $c->req->params->{level3};
        my $l4 = $c->req->params->{level4};
                 
        # Check search not already done
        if ( !$c->session->{user_selection}
            ->{ $l2 . "--" . $l3 . "--" . $l4 } ) {

            my $select_cols = [
                'me.level3',       'me.level4',
                'me.starlite',     'me.drugstore',
                'me.domain_count', 'me.reference_count',
                'me.level2',
            ];

            my $details = [
                $c->model('SARfariDB::AppFamilyBrowse')->search(
                    {   'me.level2' => $l2,
                        'me.level3' => $l3,
                        'me.level4' => $l4
                    },
                    { select => $select_cols }
                    )->cursor->all
            ];

            my $json =
                [ map { map_columns( $_, $select_cols ) } @{$details} ];
            
            # Add to session
			$c->session->{user_selection}->{ $l2 . "--" . $l3 . "--" . $l4 } = $json;

            $c->res->body( '[' . join( ', ', @{$json} ) . ']' );
        }
        else {
            $c->res->body('{}');
        }
    }
}

sub userSelectCache : Local {
    my ( $self, $c ) = @_;
  
        # Check search not already done
        if (values %{$c->session->{user_selection}} ) {

            my @json = map { @{$_} } values %{$c->session->{user_selection}};
            
            $c->res->body( '[' . join( ', ', @json ) . ']' );
        }
        else {        	
            $c->res->body('{}');
        }
}

sub deleteThis : Local {
    my ( $self, $c ) = @_;

    if (   $c->req->params->{level2}
        && $c->req->params->{level3}
        && $c->req->params->{level4} ) {

        my $l2 = $c->req->params->{level2};
        my $l3 = $c->req->params->{level3};
        my $l4 = $c->req->params->{level4};

        # Check search not already done
        if ($c->session->{user_selection}->{ $l2 . "--" . $l3 . "--" . $l4 } )
        {
            delete $c->session->{user_selection}
                ->{ $l2 . "--" . $l3 . "--" . $l4 };
        }
    }
        
    $c->res->body('{}');
}

sub getSelected : Local {
    my ( $self, $c ) = @_;

    my $json = '['
        . join( ', ',
        map { '\'' . $_ . '\'' } keys %{ $c->session->{user_selection} } )
        . ']';

    $c->res->body($json);
}

sub level2Search : Local {
    my ( $self, $c ) = @_;

    if ( $c->req->params->{level2} ) {

        my $select_cols = [
            'me.level3',       'me.level4',
            'me.starlite',     'me.drugstore',
            'me.domain_count', 'me.reference_count'
        ];

        my $details = [
            $c->model('SARfariDB::AppFamilyBrowse')->search(
                'me.level2' => $c->req->params->{level2},
                { select => $select_cols }
                )->cursor->all
        ];

        my $json = [ map { map_columns( $_, $select_cols ) } @{$details} ];

        $c->res->body( '[' . join( ', ', @{$json} ) . ']' );
    }
}

sub map_columns {
    my $data = shift;
    my $cols = shift;

    my $mapped = [];

    for ( my $i = 0; $i < scalar( @{$data} ); $i++ ) {
        my $tmp = $cols->[$i];
        $tmp =~ s/^\w+\.//;    # Remove table alias
        push( @{$mapped}, "'$tmp': '$data->[$i]'" );
    }

    return "{" . join( ', ', @{$mapped} ) . "}";
}

sub treeSearch : Local {
    my ( $self, $c ) = @_;

    my $DOMIDS = {};

    foreach my $class ( keys %{ $c->session->{user_selection} } ) {
        my ( $l2, $l3, $l4 ) = split( /--/, $class );

        my $filter = "   (trim(classification.level2) = \'$l2\' 
                      AND trim(classification.level3) = \'$l3\'
                      AND trim(classification.level4) = \'$l4\')";

        my $ids = [
            $c->model('SARfariDB::ProtDomain')->search(
                undef,
                {   select => [qw/ dom_id /],
                    join   => [ { 'gene_domain' => 'classification' } ]
                }
                )->search_literal($filter)->cursor->all
        ];

        foreach my $id ( @{$ids} ) {
            $DOMIDS->{ $id->[0] } = 1;
        }
    }    

    $c->req->params->{'targetType'} = "domid";
    $c->req->params->{'targetList'} = join( "\n", keys %{$DOMIDS} );

    #delete $c->session->{user_selection};

    $c->detach('/protein/search');
}

1;
