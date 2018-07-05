package SARfari::Schema::SARfariSchema::AppSearchFieldComp;
# $Id: AppSearchFieldComp.pm 155 2009-08-25 11:02:39Z mdavies $

# SEE LICENSE

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");

__PACKAGE__->table("APP_SEARCH_FIELD_COMP");

__PACKAGE__->add_columns(
  "sarregno",
  { data_type => "INTEGER", is_nullable => 0, size => undef },
  "field",
  { data_type => "VARCHAR2", is_nullable => 0, size => undef }
);

__PACKAGE__->set_primary_key('sarregno');

1;