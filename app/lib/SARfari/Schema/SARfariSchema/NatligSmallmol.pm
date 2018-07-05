package SARfari::Schema::SARfariSchema::NatligSmallmol;
# $Id: NatligSmallmol.pm 239 2009-10-07 15:16:20Z mdavies $

# SEE LICENSE

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");

__PACKAGE__->table("natlig_smallmol");    

__PACKAGE__->add_columns(
    "ligand_id",
    { data_type => "integer", is_nullable => 0, size => undef },
    "sarregno",
    { data_type => "integer", is_nullable => 0, size => undef },
);

__PACKAGE__->set_primary_key('ligand_id');

__PACKAGE__->belongs_to(
    comp_dic => 'SARfari::Schema::SARfariSchema::CompoundDictionary',
    { 'foreign.sarregno' => 'self.sarregno' }
);

__PACKAGE__->belongs_to(
    mol => 'SARfari::Schema::SARfariSchema::CompoundMols',
    { 'foreign.sarregno' => 'self.sarregno' }
);

1;
