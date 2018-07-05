package SARfari::Schema::SARfariSchema::ProtGeneDomain;
# $Id: ProtGeneDomain.pm 155 2009-08-25 11:02:39Z mdavies $

# SEE LICENSE

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");

__PACKAGE__->table("PROT_GENE_DOMAIN");

__PACKAGE__->add_columns(
  "ged_id",
  { data_type => "INTEGER", is_nullable => 0, size => undef },
  "tar_id",
  { data_type => "INTEGER", is_nullable => 0, size => undef },
  "homologue_id",
  { data_type => "INTEGER", is_nullable => 0, size => undef },
  "gene_domain_name",
  { data_type => "VARCHAR2", is_nullable => 0, size => undef },
  "pseudogene",
  { data_type => "INTEGER", is_nullable => 0, size => undef },
  "ec_number",
  { data_type => "VARCHAR2", is_nullable => 0, size => undef },
  "hugo_id",
  { data_type => "VARCHAR2", is_nullable => 0, size => undef },
  "omim",
  { data_type => "INTEGER", is_nullable => 0, size => undef },
  "domain_function",
  { data_type => "VARCHAR2", is_nullable => 0, size => undef },
);

__PACKAGE__->set_primary_key('ged_id');

__PACKAGE__->belongs_to( classification => 'SARfari::Schema::SARfariSchema::ProtClassification', 
  { 'foreign.homologue_id' => 'self.homologue_id' });  

__PACKAGE__->belongs_to( target => 'SARfari::Schema::SARfariSchema::ProtTarget', 
  { 'foreign.tar_id' => 'self.tar_id' });  

1;
