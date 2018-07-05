package SARfari::Schema::SARfariSchema::AppFamilyBrowse;
# $Id: AppFamilyBrowse.pm 155 2009-08-25 11:02:39Z mdavies $

# SEE LICENSE

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");

__PACKAGE__->table("app_family_browse");

__PACKAGE__->add_columns(
    "level2",
    { data_type => "VARCHAR2", is_nullable => 0, size => undef },
    "level3",
    { data_type => "VARCHAR2", is_nullable => 0, size => undef },
    "level4",
    { data_type => "VARCHAR2", is_nullable => 0, size => undef },    
    "starlite",
    { data_type => "INTEGER", is_nullable => 0, size => undef },
    "drugstore",
    { data_type => "INTEGER", is_nullable => 0, size => undef },     
    "domain_count",
    { data_type => "INTEGER", is_nullable => 0, size => undef },     
    "reference_count",
    { data_type => "INTEGER", is_nullable => 0, size => undef }
);

__PACKAGE__->set_primary_key("level2", "level3", "level4");

1;
