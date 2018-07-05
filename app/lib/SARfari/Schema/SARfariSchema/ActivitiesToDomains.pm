package SARfari::Schema::SARfariSchema::ActivitiesToDomains;
# $Id: ActivitiesToDomains.pm 155 2009-08-25 11:02:39Z mdavies $

# SEE LICENSE

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");

__PACKAGE__->table("ACTIVITIES_TO_DOMAINS");

__PACKAGE__->resultset_class(
    'SARfari::Schema::ResultSet::RsActivitiesToDomains');

__PACKAGE__->add_columns(
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
    "tid",              { data_type => 'number',   is_nullable => 0 }
);

__PACKAGE__->belongs_to(
    compound_cache => 'SARfari::Schema::SARfariSchema::AppBioSearchCmpdCache',
    { 'foreign.regno' => 'self.sarregno' }
);

__PACKAGE__->belongs_to(
    target_cache =>
        'SARfari::Schema::SARfariSchema::AppBioSearchTargetCache',   
    { 'foreign.dom_id' => 'self.dom_id' }
);

1;
