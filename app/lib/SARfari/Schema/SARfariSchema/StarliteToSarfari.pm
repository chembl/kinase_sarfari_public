package SARfari::Schema::SARfariSchema::StarliteToSarfari;
# $Id: StarliteToSarfari.pm 155 2009-08-25 11:02:39Z mdavies $

# SEE LICENSE

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");

__PACKAGE__->table("starlite_to_sarfari");

__PACKAGE__->add_columns(
    "tid",    { data_type => "integer", is_nullable => 0, size => undef },
    "dom_id", { data_type => "integer", is_nullable => 0, size => undef }    
);

__PACKAGE__->set_primary_key( 'tid', 'dom_id' );

1;
