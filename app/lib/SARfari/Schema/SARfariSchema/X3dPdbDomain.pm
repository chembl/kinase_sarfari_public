package SARfari::Schema::SARfariSchema::X3dPdbDomain;
# $Id: X3dPdbDomain.pm 155 2009-08-25 11:02:39Z mdavies $

# SEE LICENSE

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");

__PACKAGE__->table('x3d_pdb_domain');

__PACKAGE__->resultset_class('SARfari::Schema::ResultSet::RsX3dPdbDomain');    

__PACKAGE__->add_columns(
    "sunid_px",           { data_type => 'number',   is_nullable => 0 },
    "pdb_code",           { data_type => 'varchar2', is_nullable => 1 },
    "pdb_chain",          { data_type => 'varchar2', is_nullable => 1 },
    "atomres_from",       { data_type => 'varchar2', is_nullable => 1 },
    "atomres_to",         { data_type => 'varchar2', is_nullable => 1 },
    "atomres_domain_seq", { data_type => 'varchar2', is_nullable => 1 },
    "uniprot_code",       { data_type => 'varchar2', is_nullable => 1 },
    "uniprot_from",       { data_type => 'number',   is_nullable => 1 },
    "uniprot_to",         { data_type => 'number',   is_nullable => 1 },
    "uniprot_domain_seq", { data_type => 'varchar2', is_nullable => 1 },
    "tax_id",             { data_type => 'integer',  is_nullable => 1 },
    "activated",          { data_type => 'integer',  is_nullable => 1 },
    "domain_file",        { data_type => 'blob',     is_nullable => 1 }
);

__PACKAGE__->set_primary_key('sunid_px');

__PACKAGE__->belongs_to(
    pdb => 'SARfari::Schema::SARfariSchema::X3dPdb',
    { 'foreign.pdb_code' => 'self.pdb_code' }
);

__PACKAGE__->belongs_to(
    counts => 'SARfari::Schema::SARfariSchema::X3dCounts',
    { 'foreign.sunid_px' => 'self.sunid_px' }
);

__PACKAGE__->has_many(
    pdb_ligs => 'SARfari::Schema::SARfariSchema::X3dLigandToPdb',
    { 'foreign.sunid_px' => 'self.sunid_px' }
);

__PACKAGE__->has_many(
    aln_pos => 'SARfari::Schema::SARfariSchema::X3dAlignmentPositions',
    { 'foreign.sunid_px' => 'self.sunid_px' }
);

1;
