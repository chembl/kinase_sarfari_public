package SARfari::Schema::SARfariSchema::SiteDefinitions;
# $Id: SiteDefinitions.pm 155 2009-08-25 11:02:39Z mdavies $

# SEE LICENSE

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");

__PACKAGE__->table("SITE_DEFINITIONS");

__PACKAGE__->resultset_class('SARfari::Schema::ResultSet::RsSiteDefinitions');

__PACKAGE__->add_columns(
    "site_id",
    { data_type => "integer", is_nullable => 0, size => undef },
    "aln_pos",
    { data_type => "integer", is_nullable => 0, size => undef },
    "weighting",
    { data_type => "number", is_nullable => 0, size => undef },
);

__PACKAGE__->set_primary_key( 'site_id', 'aln_pos' );

__PACKAGE__->has_many(
    aln_positions =>
        'SARfari::Schema::SARfariSchema::AlignmentPositions',    
    { 'foreign.aln_pos' => 'self.aln_pos' }
);

1;
