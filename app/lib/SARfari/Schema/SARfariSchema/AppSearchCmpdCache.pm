package SARfari::Schema::SARfariSchema::AppSearchCmpdCache;
# $Id: AppSearchCmpdCache.pm 155 2009-08-25 11:02:39Z mdavies $

# SEE LICENSE

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");

__PACKAGE__->table("app_search_cmpd_cache");

__PACKAGE__->add_columns(
    "int_pk",
    { data_type => "INTEGER", is_nullable => 0, size => undef },
    "job_id",
    { data_type => "INTEGER", is_nullable => 0, size => undef },    
    "sarregno",
    { data_type => "INTEGER", is_nullable => 0, size => undef }
);

1;