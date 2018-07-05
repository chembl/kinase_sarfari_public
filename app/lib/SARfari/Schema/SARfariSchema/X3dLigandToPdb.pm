package SARfari::Schema::SARfariSchema::X3dLigandToPdb;
# $Id: X3dLigandToPdb.pm 155 2009-08-25 11:02:39Z mdavies $

# SEE LICENSE

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");

__PACKAGE__->table('x3d_ligand_to_pdb');

__PACKAGE__->resultset_class('SARfari::Schema::ResultSet::RsX3dLigandToPdb');

__PACKAGE__->add_columns(
    "sarregno", { data_type => 'number',   is_nullable => 0 },    
    "pdb_code", { data_type => 'varchar2', is_nullable => 0 },
    "het_code", { data_type => 'varchar2', is_nullable => 0 },
    "sunid_px", { data_type => 'varchar2', is_nullable => 0 },
    "source",   { data_type => 'varchar2', is_nullable => 0 }
);

1;
