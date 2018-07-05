package SARfari::Schema::SARfariSchema::AppCmpdSearchCache;
# $Id: AppCmpdSearchCache.pm 293 2009-10-22 09:14:20Z mdavies $

# SEE LICENSE

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");

__PACKAGE__->table("app_cmpd_search_cache");

__PACKAGE__->resultset_class('SARfari::Schema::ResultSet::RsAppCmpdSearchCache');

__PACKAGE__->add_columns(
    "int_pk",     { data_type => 'integer',  is_nullable => 0 },
    "job_id",     { data_type => 'integer',  is_nullable => 0 },
    "sarregno",   { data_type => 'number',   is_nullable => 0 },
    "synonyms",   { data_type => 'varchar2', is_nullable => 0 },
    "idmaps",     { data_type => 'varchar2', is_nullable => 0 },
    "similarity", { data_type => 'varchar2', is_nullable => 0 },
    "molweight",  { data_type => 'number',   is_nullable => 0 },
    "alogp",      { data_type => 'number',   is_nullable => 0 },
    "hba",        { data_type => 'integer',  is_nullable => 0 },
    "hbd",        { data_type => 'integer',  is_nullable => 0 },
    "psa",        { data_type => 'number',   is_nullable => 0 },
    "ro3_pass",   { data_type => 'varchar2', is_nullable => 0 },
    "num_ro5_violations",
    { data_type => 'varchar2', is_nullable => 0 },    
    "rtb",          { data_type => 'integer',  is_nullable => 0 },
    "chime_string", { data_type => 'varchar2', is_nullable => 0 },
    "sources", { data_type => 'varchar2', is_nullable => 0 }    
);

__PACKAGE__->set_primary_key('int_pk');

__PACKAGE__->belongs_to(
    compound => 'SARfari::Schema::SARfariSchema::CompoundMols',
    { 'foreign.sarregno' => 'self.sarregno' }
);

1;
