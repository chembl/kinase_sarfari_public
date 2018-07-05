package SARfari::Schema::SARfariSchema::SiteDomainDistance;
# $Id: SiteDomainDistance.pm 155 2009-08-25 11:02:39Z mdavies $

# SEE LICENSE

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");

__PACKAGE__->table("SITE_DOMAIN_DISTANCE");    

__PACKAGE__->add_columns(
    "dom_id",
    { data_type => "INTEGER", is_nullable => 0, size => undef },
    "site",
    { data_type => "INTEGER", is_nullable => 0, size => undef },
    "distances",
    { data_type => "CLOB", is_nullable => 0, size => undef },
);

__PACKAGE__->set_primary_key('site','dom_id');

1;
