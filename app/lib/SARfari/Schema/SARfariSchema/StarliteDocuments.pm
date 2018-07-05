package SARfari::Schema::SARfariSchema::StarliteDocuments;
# $Id: StarliteDocuments.pm 155 2009-08-25 11:02:39Z mdavies $

# SEE LICENSE

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");

__PACKAGE__->table("STARLITE_DOCUMENTS");

__PACKAGE__->add_columns(
  "doc_id",
  { data_type => "NUMBER", is_nullable => 0, size => undef },
  "journal",
  { data_type => "VARCHAR2", is_nullable => 0, size => undef },
  "year",
  { data_type => "VARCHAR2", is_nullable => 0, size => undef },
  "volume",
  { data_type => "VARCHAR2", is_nullable => 0, size => undef },
  "issue",
  { data_type => "VARCHAR2", is_nullable => 0, size => undef },
  "first_page",
  { data_type => "VARCHAR2", is_nullable => 0, size => undef },
  "last_page",
  { data_type => "VARCHAR2", is_nullable => 0, size => undef },
  "pubmed_id",
  { data_type => "NUMBER", is_nullable => 0, size => undef },
);

__PACKAGE__->set_primary_key('doc_id');

1;
