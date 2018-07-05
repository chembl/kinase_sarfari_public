package SARfari::Schema::SARfariSchema::AppSearchTargetCache;
# $Id: AppSearchTargetCache.pm 155 2009-08-25 11:02:39Z mdavies $

# SEE LICENSE

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");

__PACKAGE__->table("app_search_target_cache");

__PACKAGE__->resultset_class('SARfari::Schema::ResultSet::RsAppSearchTargetCache');

__PACKAGE__->add_columns(
    "int_pk", { data_type => "INTEGER",  is_nullable => 0, size => undef },
    "job_id", { data_type => "INTEGER",  is_nullable => 0, size => undef },
    "dom_id", { data_type => "VARCHAR2", is_nullable => 0, size => undef }
);

__PACKAGE__->set_primary_key('int_pk');

__PACKAGE__->has_many(
    act2dom => 'SARfari::Schema::SARfariSchema::ActivitiesToDomains',
    { 'foreign.dom_id' => 'self.dom_id' }
);

1;
