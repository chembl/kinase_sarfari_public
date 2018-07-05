package SARfari::Schema::SARfariSchema::AppActivitiesToDomains;
# $Id: AppActivitiesToDomains.pm 155 2009-08-25 11:02:39Z mdavies $

# SEE LICENSE

use strict;
use base 'DBIx::Class';

__PACKAGE__->load_components(qw/ Core /);

__PACKAGE__->table('app_activities_to_domains');

__PACKAGE__->add_columns(
    "dom_id",           { data_type => 'number',   is_nullable => 0 },
    "gene_domain_name", { data_type => 'varchar2', is_nullable => 0 },
    "display_name",     { data_type => 'varchar2', is_nullable => 0 },
    "assay_type",       { data_type => 'varchar2', is_nullable => 0 },
    "source",           { data_type => 'char',     is_nullable => 0 },
    "activity_type",    { data_type => 'varchar2', is_nullable => 0 }
);    

__PACKAGE__->belongs_to(
    target_cache => 'SARfari::Schema::SARfariSchema::AppSearchTargetCache',
    { 'foreign.dom_id' => 'self.dom_id' }
);

1;
