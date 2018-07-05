package SARfari::Schema::SARfariSchema::ProtDomain;
# $Id: ProtDomain.pm 155 2009-08-25 11:02:39Z mdavies $

# SEE LICENSE

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");

__PACKAGE__->table("prot_domain");

__PACKAGE__->resultset_class('SARfari::Schema::ResultSet::RsProtDomain');

__PACKAGE__->add_columns(
  "dom_id",
  { data_type => "INTEGER", is_nullable => 0, size => undef },
  "ged_id",
  { data_type => "INTEGER", is_nullable => 0, size => undef },
  "transcript",
  { data_type => "VARCHAR2", is_nullable => 0, size => undef },
  "description",
  { data_type => "VARCHAR2", is_nullable => 0, size => undef },
  "drugstore",
  { data_type => "INTEGER", is_nullable => 0, size => undef },
  "starlite",
  { data_type => "NUMBER", is_nullable => 0, size => undef },
  "inactive",
  { data_type => "INTEGER", is_nullable => 0, size => undef },
  "display_name",
  { data_type => "VARCHAR2", is_nullable => 0, size => undef },
);

__PACKAGE__->set_primary_key('dom_id');

__PACKAGE__->belongs_to( gene_domain => 'SARfari::Schema::SARfariSchema::ProtGeneDomain', 
  { 'foreign.ged_id' => 'self.ged_id' });
  
__PACKAGE__->belongs_to( alignment => 'SARfari::Schema::SARfariSchema::Alignment', 
  { 'foreign.dom_id' => 'self.dom_id' });
  
__PACKAGE__->belongs_to( prot_comp => 'SARfari::Schema::SARfariSchema::AppTargetReportComp', 
  { 'foreign.dom_id' => 'self.dom_id' });  
  
__PACKAGE__->belongs_to( prot_bio => 'SARfari::Schema::SARfariSchema::AppTargetReportBio', 
  { 'foreign.dom_id' => 'self.dom_id' });  

__PACKAGE__->belongs_to( prot_selsets => 'SARfari::Schema::SARfariSchema::AppTargetReportSelsets', 
  { 'foreign.dom_id' => 'self.dom_id' });
  
__PACKAGE__->belongs_to( nd_sites => 'SARfari::Schema::SARfariSchema::SiteNdScores', 
  { 'foreign.dom_id' => 'self.dom_id' });    
                
__PACKAGE__->has_many( search_fields => 'SARfari::Schema::SARfariSchema::AppSearchField', 
  { 'foreign.dom_id' => 'self.dom_id' });
  
__PACKAGE__->has_many( synonyms => 'SARfari::Schema::SARfariSchema::ProtSynonym', 
  { 'foreign.dom_id' => 'self.dom_id' });
  
__PACKAGE__->has_many( accessions => 'SARfari::Schema::SARfariSchema::ProtAccession', 
  { 'foreign.dom_id' => 'self.dom_id' });
  
    
1;
