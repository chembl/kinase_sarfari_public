package SARfari::Schema::SARfariSchema::X3dAlignment;
# $Id: X3dAlignment.pm 155 2009-08-25 11:02:39Z mdavies $

# SEE LICENSE

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");

__PACKAGE__->table('x3d_alignment');

__PACKAGE__->add_columns(
    "sunid_px", { data_type => 'number',   is_nullable => 0 },
    "aln",      { data_type => 'varchar2', is_nullable => 0 },
    "sequence", { data_type => 'varchar2', is_nullable => 0 },
    "md5",      { data_type => 'varchar2', is_nullable => 0 }
);

__PACKAGE__->set_primary_key('sunid_px');

__PACKAGE__->belongs_to(
    pdb_domain => 'SARfari::Schema::SARfariSchema::x3d_pdb_domain',  
    { 'foreign.sunid_px' => 'self.sunid_px' }
);

1;
