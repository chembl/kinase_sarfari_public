package SARfari::Schema::SARfariSchema::CompoundMols;
# $Id: CompoundMols.pm 240 2009-10-07 15:54:42Z mdavies $

# SEE LICENSE

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");

__PACKAGE__->table("compound_mols");    

__PACKAGE__->add_columns(
    "sarregno",
    { data_type => "integer", is_nullable => 0, size => undef },
    "ctab",
    { data_type => "blob", is_nullable => 0, size => undef },
    "molweight",
    { data_type => "number", is_nullable => 0, size => undef },
    "molformula",
    { data_type => "clob", is_nullable => 0, size => undef },
    "inchi",
    { data_type => "clob", is_nullable => 0, size => undef },
    "inchi_key",
    { data_type => "varchar2", is_nullable => 0, size => undef },
    "smiles",
    { data_type => "varchar2", is_nullable => 0, size => undef },
);

__PACKAGE__->set_primary_key('sarregno');

1;

