package SARfari::Schema::SARfariSchema::StarliteActivities;
# $Id: StarliteActivities.pm 155 2009-08-25 11:02:39Z mdavies $

# SEE LICENSE

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");

__PACKAGE__->table("STARLITE_ACTIVITIES");

__PACKAGE__->add_columns(
    "activity_id",
    { data_type => "NUMBER", is_nullable => 0, size => undef },
    "cmpb_id",
    { data_type => "NUMBER", is_nullable => 0, size => undef },
    "sarregno",
    { data_type => "INTEGER", is_nullable => 0, size => undef },
    "activity_type",
    { data_type => "TEXT", is_nullable => 0, size => undef },
    "relation",
    { data_type => "TEXT", is_nullable => 0, size => undef },
    "reported_value",
    { data_type => "NUMBER", is_nullable => 0, size => undef },
    "reported_unit",
    { data_type => "TEXT", is_nullable => 0, size => undef },
    "standard_value",
    { data_type => "NUMBER", is_nullable => 0, size => undef },
    "standard_unit",
    { data_type => "TEXT", is_nullable => 0, size => undef },
    "sl_assay_id",
    { data_type => "INTEGER", is_nullable => 0, size => undef },
    "sl_activity_id",
    { data_type => "INTEGER", is_nullable => 0, size => undef },
    "sl_activity_comment",
    { data_type => "TEXT", is_nullable => 0, size => undef },
);

__PACKAGE__->set_primary_key('activity_id');

__PACKAGE__->belongs_to(
    star_assay => 'SARfari::Schema::SARfariSchema::StarliteAssays',
    { 'foreign.sl_assay_id' => 'self.sl_assay_id' }, { 'join_type' => 'left' }
);

__PACKAGE__->belongs_to(    
    batch => 'SARfari::Schema::SARfariSchema::CompoundBatches',
    { 'foreign.cmpb_id' => 'self.cmpb_id' }, { 'join_type' => 'left' }
);

1;
