package SARfari::Schema::SARfariSchema::ProtAccession;
# $Id: ProtAccession.pm 141 2009-08-25 10:25:01Z mdavies $

# SEE LICENSE

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");

__PACKAGE__->table("PROT_ACCESSION");

__PACKAGE__->resultset_class('SARfari::Schema::ResultSet::RsProtAccession');

__PACKAGE__->add_columns(
  "int_pk",
  { data_type => "integer", is_nullable => 0, size => undef },
  "dom_id",
  { data_type => "integer", is_nullable => 0, size => undef },
  "accession",
  { data_type => "varchar2", is_nullable => 0, size => undef },
  "accession_source",
  { data_type => "varchar2", is_nullable => 0, size => undef },
  "fragment",
  { data_type => "integer", is_nullable => 0, size => undef },
  "accession_sequence",
  { data_type => "varchar2", is_nullable => 0, size => undef },
);

__PACKAGE__->set_primary_key('int_pk');

__PACKAGE__->belongs_to( domain => 'SARfari::Schema::SARfariSchema::ProtDomain', 
  { 'foreign.dom_id' => 'self.dom_id' });

1;