package SARfari::Schema::SARfariSchema::StarliteActivitiesToDomains;
# $Id: StarliteActivitiesToDomains.pm 155 2009-08-25 11:02:39Z mdavies $

# SEE LICENSE

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("STARLITE_ACTIVITIES_TO_DOMAINS");
__PACKAGE__->add_columns(
  "activity_id",
  { data_type => "INTEGER", is_nullable => 0, size => undef },
  "tid",
  { data_type => "INTEGER", is_nullable => 0, size => undef },
  "dom_id",
  { data_type => "NUMBER", is_nullable => 0, size => undef },
  "confidence",
  { data_type => "TEXT", is_nullable => 0, size => undef },
  "complex",
  { data_type => "TEXT", is_nullable => 0, size => undef },
  "multi",
  { data_type => "TEXT", is_nullable => 0, size => undef },
  "assay_tax_id",
  { data_type => "NUMBER", is_nullable => 0, size => undef },
);

1;
