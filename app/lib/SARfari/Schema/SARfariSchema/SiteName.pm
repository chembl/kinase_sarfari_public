package SARfari::Schema::SARfariSchema::SiteName;
# $Id: SiteName.pm 155 2009-08-25 11:02:39Z mdavies $

# SEE LICENSE

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");

__PACKAGE__->table("site_name");

__PACKAGE__->add_columns(
  "site_id",
  { data_type => "integer", is_nullable => 0, size => undef },
  "name",
  { data_type => "varchar2", is_nullable => 0, size => undef },
  "description",
  { data_type => "varchar2", is_nullable => 0, size => undef },
  "label",
  { data_type => "varchar2", is_nullable => 0, size => undef },
);

__PACKAGE__->set_primary_key('site_id');

1;
