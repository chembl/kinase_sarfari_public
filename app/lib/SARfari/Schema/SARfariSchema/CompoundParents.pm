package SARfari::Schema::SARfariSchema::CompoundParents;
# $Id: CompoundParents.pm 155 2009-08-25 11:02:39Z mdavies $

# SEE LICENSE

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("COMPOUND_PARENTS");
__PACKAGE__->add_columns(
    "sarregno",
    { data_type => "INTEGER", is_nullable => 0, size => undef },
    "parent_sarregno",
    { data_type => "INTEGER", is_nullable => 0, size => undef },
);

__PACKAGE__->set_primary_key('sarregno','parent_sarregno');

1;
