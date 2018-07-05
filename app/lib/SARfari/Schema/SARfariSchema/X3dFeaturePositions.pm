package SARfari::Schema::SARfariSchema::X3dFeaturePositions;
# $Id: X3dFeaturePositions.pm 155 2009-08-25 11:02:39Z mdavies $

# SEE LICENSE

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");

__PACKAGE__->table('x3d_feature_positions');

__PACKAGE__->resultset_class('SARfari::Schema::ResultSet::RsX3dFeaturePositions'); 


__PACKAGE__->add_columns(
    "feature_id",   { data_type => 'integer', is_nullable => 1 },
    "aln_position", { data_type => 'integer', is_nullable => 1 }
);

__PACKAGE__->belongs_to(
    feature => 'SARfari::Schema::SARfariSchema::X3dFeature',
    { 'foreign.feature_id' => 'self.feature_id' }
);

__PACKAGE__->has_many(
    aln => 'SARfari::Schema::SARfariSchema::X3dAlignmentPositions',
    { 'foreign.aln_pos' => 'self.aln_position' }
);

1;