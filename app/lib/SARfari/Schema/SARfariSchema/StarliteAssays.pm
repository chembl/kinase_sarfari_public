package SARfari::Schema::SARfariSchema::StarliteAssays;
# $Id: StarliteAssays.pm 155 2009-08-25 11:02:39Z mdavies $

# SEE LICENSE
use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");

__PACKAGE__->table("STARLITE_ASSAYS");

__PACKAGE__->add_columns(
  "sl_assay_id",
  { data_type => "INTEGER", is_nullable => 0, size => undef },
  "assay_type",
  { data_type => "VARCHAR2", is_nullable => 0, size => undef },
  "description",
  { data_type => "VARCHAR2", is_nullable => 0, size => undef },
);

__PACKAGE__->set_primary_key('sl_assay_id');

1;
