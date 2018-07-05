package SARfari::Schema::SARfariSchema::X3dAlignmentPositions;
# $Id: X3dAlignmentPositions.pm 793 2012-03-08 14:11:04Z mdavies $

# SEE LICENSE

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");

__PACKAGE__->table('x3d_alignment_positions');

__PACKAGE__->add_columns(
    "px",         { data_type => 'integer',  is_nullable => 0 },
    "seq_pos",    { data_type => 'integer',  is_nullable => 0 },
    "residue",    { data_type => 'varchar2', is_nullable => 1 },
    "aln_pos",    { data_type => 'integer',  is_nullable => 0 },
    "pdb_resnum", { data_type => 'varchar2', is_nullable => 0 }
);

__PACKAGE__->set_primary_key('px','seq_pos');

__PACKAGE__->has_many(
    site_defs => 'SARfari::Schema::SARfariSchema::SiteDefinitions',
    { 'foreign.aln_pos' => 'self.aln_pos' }
);

1;
