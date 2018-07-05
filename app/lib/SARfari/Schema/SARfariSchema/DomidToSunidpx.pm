package SARfari::Schema::SARfariSchema::DomidToSunidpx;
# $Id: DomidToSunidpx.pm 155 2009-08-25 11:02:39Z mdavies $

# SEE LICENSE

use strict;
use base 'DBIx::Class';
use Data::Dumper;

__PACKAGE__->load_components("Core");

__PACKAGE__->table('domid_to_sunidpx');

__PACKAGE__->resultset_class('SARfari::Schema::ResultSet::RsDomidToSunidpx');

__PACKAGE__->add_columns(
    "dom_id",            { data_type => 'integer', is_nullable => 1 },
    "sunid_px",          { data_type => 'integer', is_nullable => 1 },
    "relationship_rank", { data_type => 'integer', is_nullable => 0 },
);

__PACKAGE__->set_primary_key( 'dom_id', 'sunid_px' );

__PACKAGE__->belongs_to( domain => 'SARfari::Schema::SARfariSchema::ProtDomain', 
  { 'foreign.dom_id' => 'self.dom_id' });

__PACKAGE__->belongs_to( x3d_domain => 'SARfari::Schema::SARfariSchema::X3dPdbDomain', 
  { 'foreign.sunid_px' => 'self.sunid_px' });


1;
