package SARfari::Schema::SARfariSchema::SiteProfiles;
# $Id: SiteProfiles.pm 155 2009-08-25 11:02:39Z mdavies $

# SEE LICENSE

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("SITE_PROFILES");
__PACKAGE__->add_columns(
  "gpcrdid",
  { data_type => "INTEGER", is_nullable => 0, size => undef },
  "aaindex_id",
  { data_type => "TEXT", is_nullable => 0, size => undef },
  "site_id",
  { data_type => "INTEGER", is_nullable => 0, size => undef },
  "weighted_profile",
  { data_type => "TEXT", is_nullable => 0, size => undef },
  "normal_profile",
  { data_type => "TEXT", is_nullable => 0, size => undef },
);

1;
