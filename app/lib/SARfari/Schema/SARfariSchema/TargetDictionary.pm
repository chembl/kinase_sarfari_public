package SARfari::Schema::SARfariSchema::TargetDictionary;
# created by kaz manually in 2011, if needed you should fix

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");

__PACKAGE__->table("target_dictionary");

__PACKAGE__->add_columns(

  "tid", 
  { data_type => "INTEGER", is_nullable => 0, size => undef },
  "target_type", 
  { data_type => "VARCHAR2", is_nullable => 0, size => undef },
  "db_source", 
  { data_type => "VARCHAR2", is_nullable => 0, size => undef },
  "uan", 
  { data_type => "INTEGER", is_nullable => 0, size => undef },
  "description", 
  { data_type => "VARCHAR2", is_nullable => 0, size => undef },
  "gene_names", 
  { data_type => "VARCHAR2", is_nullable => 0, size => undef },
  "pref_name", 
  { data_type => "VARCHAR2", is_nullable => 0, size => undef },
  "synonyms", 
  { data_type => "VARCHAR2", is_nullable => 0, size => undef },
  "keywords", 
  { data_type => "VARCHAR2", is_nullable => 0, size => undef },
  "protein_sequence", 
  { data_type => "VARCHAR2", is_nullable => 0, size => undef },
  "protein_md5sum", 
  { data_type => "VARCHAR2", is_nullable => 0, size => undef },
  "tax_id", 
  { data_type => "INTEGER", is_nullable => 0, size => undef },
  "organism", 
  { data_type => "VARCHAR2", is_nullable => 0, size => undef },
  "tissue", 
  { data_type => "VARCHAR2", is_nullable => 0, size => undef },
  "strain", 
  { data_type => "VARCHAR2", is_nullable => 0, size => undef },
  "taxonomy_summary", 
  { data_type => "VARCHAR2", is_nullable => 0, size => undef },
  "db_version", 
  { data_type => "VARCHAR2", is_nullable => 0, size => undef },
  "cell_line", 
  { data_type => "VARCHAR2", is_nullable => 0, size => undef },
  "in_drugstore", 
  { data_type => "INTEGER", is_nullable => 0, size => undef },
  "in_starlite", 
  { data_type => "INTEGER", is_nullable => 0, size => undef },
  "qa_status", 
  { data_type => "VARCHAR2", is_nullable => 0, size => undef },
  "protein_accession", 
  { data_type => "VARCHAR2", is_nullable => 0, size => undef },
  "updated_on", 
  { data_type => "DATE", is_nullable => 0, size => undef },
  "updated_by", 
  { data_type => "VARCHAR2", is_nullable => 0, size => undef },
  "popularity", 
  { data_type => "INTEGER", is_nullable => 0, size => undef },
  "chembl_id",
  { data_type => "VARCHAR2", is_nullable => 0, size => undef },

);

__PACKAGE__->set_primary_key('tid');


__PACKAGE__->belongs_to( starlite_to_sarfari => 'SARfari::Schema::SARfariSchema::StarliteToSarfari',
  { 'foreign.tid' => 'self.tid' });


1;
