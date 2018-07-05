package SARfari::Schema::SARfariSchema::ProtSequence;
# $Id: ProtSequence.pm 155 2009-08-25 11:02:39Z mdavies $

# SEE LICENSE

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("PROT_SEQUENCE");
__PACKAGE__->add_columns(
  "dom_id",
  { data_type => "INTEGER", is_nullable => 0, size => undef },
  "domain_sequence",
  { data_type => "TEXT", is_nullable => 0, size => undef },
);

1;
