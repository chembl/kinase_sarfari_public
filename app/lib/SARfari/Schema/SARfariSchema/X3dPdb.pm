package SARfari::Schema::SARfariSchema::X3dPdb;
# $Id: X3dPdb.pm 155 2009-08-25 11:02:39Z mdavies $

# SEE LICENSE

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");

__PACKAGE__->table('x3d_pdb');

__PACKAGE__->add_columns(
    "pdb_code",           { data_type => 'varchar2', is_nullable => 0 },
    "date_created",       { data_type => 'date',     is_nullable => 1 },
    "description",        { data_type => 'varchar2', is_nullable => 1 },
    "resolution",         { data_type => 'number',   is_nullable => 1 },
    "r_value",            { data_type => 'number',   is_nullable => 1 },
    "free_r_value",       { data_type => 'number',   is_nullable => 1 },
    "space_group",        { data_type => 'varchar2', is_nullable => 0 },
    "refinement_program", { data_type => 'varchar2', is_nullable => 0 },
    "pdb_file",           { data_type => 'blob',     is_nullable => 0 },
    "source",             { data_type => 'varchar2', is_nullable => 0 }
);

__PACKAGE__->set_primary_key('pdb_code');

1;
