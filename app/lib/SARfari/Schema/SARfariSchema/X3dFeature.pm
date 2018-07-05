package SARfari::Schema::SARfariSchema::X3dFeature;
# $Id: X3dFeature.pm 155 2009-08-25 11:02:39Z mdavies $

# SEE LICENSE

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");

__PACKAGE__->table('x3d_feature');

__PACKAGE__->add_columns(
    "feature_id",   { data_type => 'integer',  is_nullable => 1 },
    "feature_name", { data_type => 'varchar2', is_nullable => 1 }
);

__PACKAGE__->set_primary_key('feature_id');

1;
