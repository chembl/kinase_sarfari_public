package SARfari::Schema::SARfariSchema::AppBioSearchJobs;
# $Id: AppBioSearchJobs.pm 155 2009-08-25 11:02:39Z mdavies $

# SEE LICENSE

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");

__PACKAGE__->table("app_bio_search_jobs");

__PACKAGE__->add_columns(
    "job_id",
    { data_type => "INTEGER", is_nullable => 0, size => undef },
    "session_id",
    { data_type => "VARCHAR2", is_nullable => 0, size => undef },
    "username",
    { data_type => "VARCHAR2", is_nullable => 0, size => undef },    
    "query_type",
    { data_type => "VARCHAR2", is_nullable => 0, size => undef },
    "query_start",
    { data_type => "DATE", is_nullable => 0, size => undef },
    "query_finish",
    { data_type => "DATE", is_nullable => 0, size => undef },
    "query_count",
    { data_type => "INTEGER", is_nullable => 0, size => undef },
    "query_sql",
    { data_type => "INTEGER", is_nullable => 0, size => undef }      
);

__PACKAGE__->set_primary_key('job_id');

1;
