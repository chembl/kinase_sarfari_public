package SARfari::Schema::ResultSet::RsDomidToSunidpx;
# $Id: RsDomidToSunidpx.pm 155 2009-08-25 11:02:39Z mdavies $

# SEE LICENSE

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use Carp;
use Data::Dumper;

# Returns arrayref of protein details

sub getStructureDetails {

    my ( $self, $domids, $params ) = @_;

    my $select_cols = [
        'x3d_domain.pdb_code',     'pdb.description',
        'x3d_domain.pdb_chain',    'x3d_domain.sunid_px',
        'pdb.resolution',          'pdb.r_value',
        'counts.dom_id',           'counts.transcript',
        'counts.gene_domain_name', 'counts.bio_all',
        'counts.comp_all',         'counts.ds_count'
    ];

    
    my $join = [ 'domain', { 'x3d_domain' => [ 'pdb', 'counts' ] } ];

    # Create query filters
    my $filter = {};

    if ( $params->{taxid} && $params->{taxid} =~ /^\d+$/ ) {
        $filter->{"x3d_domain.tax_id"} = $params->{taxid};
    }

    my $details;

    eval {
        $details = [
            $self->search(
                $filter,
                {   select   => $select_cols,
                    join     => $join,
                    distinct => 1,
                }
                )->search_literal(
                " me.dom_id in (" . join( ', ', @{$domids} ) . ") "
                )->cursor->all
        ];
    };

    # Pass exception up the chain
    if ($@) {
        croak($@);
    }

    my $mapped_details =
        [ map { map_columns( $_, $select_cols ) } @{$details} ];

    return $mapped_details;
}

# Quick sub to create href, mapping column names to data

sub map_columns {
    my $data = shift;
    my $cols = shift;

    my $mapped = {};

    for ( my $i = 0; $i < scalar( @{$data} ); $i++ ) {
        my $tmp = $cols->[$i];
        $tmp =~ s/^\w+\.//;    # Remove table alias
        $mapped->{$tmp} = $data->[$i];
    }

    return $mapped;
}

1;
