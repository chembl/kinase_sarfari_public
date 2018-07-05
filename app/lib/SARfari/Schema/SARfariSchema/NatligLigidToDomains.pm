package SARfari::Schema::SARfariSchema::NatligLigidToDomains;
# $Id: NatligLigidToDomains.pm 155 2009-08-25 11:02:39Z mdavies $

# SEE LICENSE

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");

__PACKAGE__->table("natlig_ligid_to_domains");

__PACKAGE__->resultset_class('SARfari::Schema::ResultSet::RsNatligLigidToDomains');

__PACKAGE__->add_columns(
  "dom_id",
  { data_type => "integer", is_nullable => 0, size => undef },
  "ligand_id",
  { data_type => "integer", is_nullable => 0, size => undef },
  "ligand_type",
  { data_type => "varchar2", is_nullable => 0, size => undef },
  "deorph_comment",
  { data_type => "varchar2", is_nullable => 0, size => undef },
);

__PACKAGE__->set_primary_key('dom_id','ligand_id');

__PACKAGE__->belongs_to(
    nl_prot => 'SARfari::Schema::SARfariSchema::NatligProtein',
    { 'foreign.ligand_id' => 'self.ligand_id' }
);

__PACKAGE__->belongs_to(
    nl_smol => 'SARfari::Schema::SARfariSchema::NatligSmallmol',
    { 'foreign.ligand_id' => 'self.ligand_id' }
);

1;