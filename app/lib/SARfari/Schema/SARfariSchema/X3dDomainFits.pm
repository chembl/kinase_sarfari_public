package SARfari::Schema::SARfariSchema::X3dDomainFits;
# $Id: X3dDomainFits.pm 155 2009-08-25 11:02:39Z mdavies $

# SEE LICENSE

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");

__PACKAGE__->table('x3d_domain_fits');

__PACKAGE__->add_columns(
    "sunid_px_1",             { data_type => 'integer',  is_nullable => 0 },
    "sunid_px_2",             { data_type => 'integer',  is_nullable => 0 },
    "vanilla_cog",            { data_type => 'varchar2', is_nullable => 0 },
    "vanilla_translation",    { data_type => 'varchar2', is_nullable => 0 },
    "vanilla_rot_mat",        { data_type => 'varchar2', is_nullable => 0 },
    "vanilla_equiv_residues", { data_type => 'integer',  is_nullable => 0 },
    "vanilla_rmsd",           { data_type => 'number',   is_nullable => 0 },
    "vanilla_norm_rmsd",      { data_type => 'number',   is_nullable => 0 },
    "ec_cbs_cog",             { data_type => 'varchar2', is_nullable => 0 },
    "ec_cbs_translation",     { data_type => 'varchar2', is_nullable => 0 },
    "ec_cbs_rot_mat",         { data_type => 'varchar2', is_nullable => 0 },
    "ec_cbs_equiv_residues",  { data_type => 'integer',  is_nullable => 0 },
    "ec_cbs_rmsd",            { data_type => 'number',   is_nullable => 0 },
    "ec_cbs_norm_rmsd",       { data_type => 'number',   is_nullable => 0 },
    "ec_ctl_cog",             { data_type => 'varchar2', is_nullable => 0 },
    "ec_ctl_translation",     { data_type => 'varchar2', is_nullable => 0 },
    "ec_ctl_rot_mat",         { data_type => 'varchar2', is_nullable => 0 },
    "ec_ctl_equiv_residues",  { data_type => 'integer',  is_nullable => 0 },
    "ec_ctl_rmsd",            { data_type => 'number',   is_nullable => 0 },
    "ec_ctl_norm_rmsd",       { data_type => 'number',   is_nullable => 0 }
);

__PACKAGE__->set_primary_key( 'sunid_px_1', 'sunid_px_2' );

__PACKAGE__->belongs_to(
    pdb_domains1 => 'SARfari::Schema::SARfariSchema::X3dPdbDomain',
    { 'foreign.sunid_px' => 'self.sunid_px_1' }
);

__PACKAGE__->belongs_to(
    pdb_domains2 => 'SARfari::Schema::SARfariSchema::X3dPdbDomain',  
    { 'foreign.sunid_px' => 'self.sunid_px_2' }
);

1;
