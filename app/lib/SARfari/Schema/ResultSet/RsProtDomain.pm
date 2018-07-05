package SARfari::Schema::ResultSet::RsProtDomain;
# $Id: RsProtDomain.pm 155 2009-08-25 11:02:39Z mdavies $

# SEE LICENSE

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use Carp;
use Data::Dumper;

# Wildcarded search against all fields

sub allToDomid {

    my ( $self, $query ) = @_;

    my $domids;

    my $quoted_string = $self->result_source->schema->storage->dbh->quote(uc($query));    
    $quoted_string =~ s/^\'/\'\%/;
    $quoted_string =~ s/\'$/\%\'/;
    
    eval {

        $domids = [
            map { $_->[0] } $self->search(
                undef,
                {   select => [qw / me.dom_id /],
                    join   => [qw / search_fields /]
                }
                )->search_literal(
                " search_fields.field like $quoted_string "
                )->cursor->all
        ];
    };

    # Pass exception up the chain
    if ($@) {
        croak($@);
    }

    return $domids;
}

# Requires exact match between use search term and target name

sub nameToDomid {

    my ( $self, $query ) = @_;

    my $domids;

    my $quoted_string = $self->result_source->schema->storage->dbh->quote(uc($query));

    eval {

        $domids = [
            map { $_->[0] } $self->search(
                undef,
                {   select => [qw / me.dom_id /],
                    join   => [ { 'gene_domain' => 'target' } ]
                }
                )->search_literal(
                " upper(target.target_name) = $quoted_string "
                )->cursor->all
        ];
    };

    # Pass exception up the chain
    if ($@) {
        croak($@);
    }

    return $domids;
}


# Returns arrayref of protein details

sub getProtDetails {

    my ( $self, $domids, $params ) = @_;

    my $select_cols = [
        'me.dom_id',                    'me.description',
        'me.display_name',              'prot_bio.bio_all',
        'prot_comp.comp_all',           'classification.level2',
        'classification.level3',        'classification.level4',
        'gene_domain.gene_domain_name', 'taxon.common_name',
        'prot_selsets.ds_count',        'prot_selsets.nlpep_names',
        'prot_selsets.nlsmol_names'
    ];

    my $join = [
        'prot_comp', 'prot_bio', 'prot_selsets',
        { 'gene_domain' => [ 'classification', { 'target' => 'taxon' } ] }
    ];

    # Create query filters
    my $filter = {};

    if ( $params->{taxid} && $params->{taxid} =~ /^\d+$/ ) {
        $filter->{"taxon.tax_id"} = $params->{taxid};
    }

    if ( $params->{site} && $params->{site} =~ /^\d+$/ ) {
        $filter->{"nd_sites.site"} = $params->{site};    

        # Need to add extra join, plus select
        push( @{$join},        'nd_sites' );
        push( @{$select_cols}, 'nd_sites.nd_score' );

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
