package SARfari::Schema::SARfariSchema::AppBioSearchCache;
# $Id: AppBioSearchCache.pm 526 2010-01-22 13:33:18Z mdavies $

# SEE LICENSE

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");

__PACKAGE__->table("app_bio_search_cache");

__PACKAGE__->resultset_class('SARfari::Schema::ResultSet::RsAppBioSearchCache');

__PACKAGE__->add_columns(
    "int_pk",           { data_type => 'integer',  is_nullable => 0 },
    "job_id",           { data_type => 'integer',  is_nullable => 0 },
    "activity_id",      { data_type => 'number',   is_nullable => 0 },
    "dom_id",           { data_type => 'number',   is_nullable => 0 },
    "display_name",     { data_type => 'varchar2', is_nullable => 0 },
    "short_name",       { data_type => 'varchar2', is_nullable => 0 },
    "transcript",       { data_type => 'varchar2', is_nullable => 0 },
    "assay_tax_id",     { data_type => 'number',   is_nullable => 0 },
    "source",           { data_type => 'varchar2', is_nullable => 0 },
    "activity_type",    { data_type => 'varchar2', is_nullable => 0 },
    "relation",         { data_type => 'varchar2', is_nullable => 0 },
    "standard_value",   { data_type => 'number',   is_nullable => 0 },
    "standard_unit",    { data_type => 'varchar2', is_nullable => 0 },
    "assay_type",       { data_type => 'varchar2', is_nullable => 0 },
    "sarregno",         { data_type => 'integer',  is_nullable => 0 },
    "doc_id",           { data_type => 'varchar2', is_nullable => 0 },
    "sl_activity_id",   { data_type => 'number',   is_nullable => 0 },
    "sl_assay_id",      { data_type => 'number',   is_nullable => 0 },
    "activity_comment", { data_type => 'varchar2', is_nullable => 0 },
    "tid",              { data_type => 'number',   is_nullable => 0 },
    "smiles",           { data_type => 'varchar2', is_nullable => 0 }
);

__PACKAGE__->set_primary_key('int_pk');    

__PACKAGE__->belongs_to(
    domain => 'SARfari::Schema::SARfariSchema::ProtDomain',
    { 'foreign.dom_id' => 'self.dom_id' }
);


__PACKAGE__->belongs_to(
    dictionary => 'SARfari::Schema::SARfariSchema::CompoundDictionary',
    { 'foreign.sarregno' => 'self.sarregno' }
);


1;
