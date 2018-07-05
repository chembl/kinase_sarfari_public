package SARfari::Schema::SARfariSchema::CompoundImages;
# $Id: CompoundImages.pm 155 2009-08-25 11:02:39Z mdavies $

# SEE LICENSE

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("COMPOUND_IMAGES");
__PACKAGE__->add_columns(
    "sarregno",
    { data_type => "INTEGER", is_nullable => 0, size => undef },
    "image",
    { data_type => "BLOB", is_nullable => 0, size => undef },
);

__PACKAGE__->set_primary_key('sarregno');

1;
