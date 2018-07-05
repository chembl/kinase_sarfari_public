package SARfari::Schema::SARfariSchema::ProtSynonym;
# $Id: ProtSynonym.pm 155 2009-08-25 11:02:39Z mdavies $

# SEE LICENSE

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("PROT_SYNONYM");
__PACKAGE__->add_columns(
  "int_pk",
  { data_type => "NUMBER", is_nullable => 0, size => undef },
  "dom_id",
  { data_type => "INTEGER", is_nullable => 0, size => undef },
  "syn",
  { data_type => "TEXT", is_nullable => 0, size => undef },
);

1;
