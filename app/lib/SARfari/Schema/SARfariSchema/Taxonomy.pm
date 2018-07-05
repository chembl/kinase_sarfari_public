package SARfari::Schema::SARfariSchema::Taxonomy;
# $Id: Taxonomy.pm 155 2009-08-25 11:02:39Z mdavies $

# SEE LICENSE

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("TAXONOMY");
__PACKAGE__->add_columns(
  "tax_id",
  { data_type => "INTEGER", is_nullable => 0, size => undef },
  "name",
  { data_type => "TEXT", is_nullable => 0, size => undef },
  "rank",
  { data_type => "TEXT", is_nullable => 0, size => undef },
);

1;
