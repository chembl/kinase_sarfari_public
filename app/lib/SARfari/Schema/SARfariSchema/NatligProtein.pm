package SARfari::Schema::SARfariSchema::NatligProtein;
# $Id: NatligProtein.pm 155 2009-08-25 11:02:39Z mdavies $

# SEE LICENSE

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");

__PACKAGE__->table("natlig_protein");

__PACKAGE__->add_columns(
    "ligand_id",
    { data_type => "integer", is_nullable => 0, size => undef },
    "name",
    { data_type => "varchar2", is_nullable => 0, size => undef },
    "description",
    { data_type => "varchar2", is_nullable => 0, size => undef },
    "peptide_accession",
    { data_type => "varchar2", is_nullable => 0, size => undef },
    "peptide_source",
    { data_type => "varchar2", is_nullable => 0, size => undef },
    "peptide_seq",
    { data_type => "varchar2", is_nullable => 0, size => undef },
    "posttrans_mod",
    { data_type => "varchar2", is_nullable => 0, size => undef },    
);

__PACKAGE__->set_primary_key('ligand_id');

1;
