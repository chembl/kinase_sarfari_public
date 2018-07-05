package SARfari::Schema::ResultSet::RsX3dPdbDomain;
# $Id: RsX3dPdbDomain.pm 155 2009-08-25 11:02:39Z mdavies $

# SEE LICENSE

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use Carp;
use Data::Dumper;

# Requires exact match between use search term and target name

sub pdbToPx {

    my ( $self, $query ) = @_;

    my $pxs;

    eval {

        $pxs = [
            map { $_->[0] }
                $self->search( undef, { select => [qw / me.sunid_px /], } )
                ->search_literal(
                " upper(me.pdb_code) = \'" . uc($query) . "\' "
                )->cursor->all
        ];
    };

    # Pass exception up the chain
    if ($@) {
        croak($@);
    }

    return $pxs;
}

# Returns arrayref of protein details

sub getStructureDetails {

    my ( $self, $domids, $params ) = @_;

    my $select_cols = [
        'me.pdb_code',             'pdb.description',
        'me.pdb_chain',            'me.sunid_px',
        'pdb.resolution',          'pdb.r_value',
        'counts.dom_id',           'counts.transcript',    
        'counts.gene_domain_name', 'counts.bio_all',
        'counts.comp_all',         'counts.ds_count'
    ];

    my $join = [ 'pdb', 'counts' ];

    # Create query filters
    my $filter = {};

    if ( $params->{taxid} && $params->{taxid} =~ /^\d+$/ ) {
        $filter->{"me.tax_id"} = $params->{taxid};
    }

    my $details;

    eval {
        $details = [
            $self->search(
                $filter,
                {   select => $select_cols,
                    join   => $join
                }
                )->search_literal(
                " me.sunid_px in (" . join( ', ', @{$domids} ) . ") "
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

sub get_structures_hash : ResultSet {
    my ( $self, $px ) = @_;

    my $cursor_list = $self->_get_structures($px);

    my $structure_details = {};

    foreach my $row ( @{$cursor_list} ) {
        $structure_details->{ $row->[0] }->{'pdb_code'}   = $row->[1];
        $structure_details->{ $row->[0] }->{'pdb_chain'}  = $row->[2];
        $structure_details->{ $row->[0] }->{'activated'}  = $row->[3];
        $structure_details->{ $row->[0] }->{'resolution'} =
            sprintf( "%.2f", $row->[4] );
        $structure_details->{ $row->[0] }->{'r_value'} =
            sprintf( "%.2f", $row->[5] );
        $structure_details->{ $row->[0] }->{'description'} = $row->[6];
        $structure_details->{ $row->[0] }->{'source'}      = $row->[7];

        if ( $row->[8] ) {
            $structure_details->{ $row->[0] }->{'ligands'}->{ $row->[8] } =
                $row->[9];
        }
    }

    return $structure_details;
}

sub _get_structures : ResultSet {
    my ( $self, $px ) = @_;

    my $str_rs = $self->search(
        'me.sunid_px' => $px,
        {   select => [
                'me.sunid_px',    #0
                'me.pdb_code',
                'me.pdb_chain',
                'me.activated',
                'pdb.resolution',
                'pdb.r_value',    #5
                'pdb.description',
                'pdb.source',
                'pdb_ligs.het_code',
                'pdb_ligs.sarregno'
            ],
            join => [ 'pdb', 'pdb_ligs', ]
        }
    );

    my $cursor = $str_rs->cursor;

    return [ $cursor->all ];
}

1;
