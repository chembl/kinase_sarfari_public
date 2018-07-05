package SARfari::Schema::SARfariSchema::ProtTarget;
# $Id: ProtTarget.pm 155 2009-08-25 11:02:39Z mdavies $

# SEE LICENSE

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");

__PACKAGE__->table("PROT_TARGET");

__PACKAGE__->add_columns(
    "tar_id",
    { data_type => "NUMBER", is_nullable => 0, size => undef },
    "target_name",
    { data_type => "TEXT", is_nullable => 0, size => undef },
    "tax_id",
    { data_type => "INTEGER", is_nullable => 0, size => undef },
);

__PACKAGE__->set_primary_key('tar_id');

__PACKAGE__->belongs_to( taxon => 'SARfari::Schema::SARfariSchema::ProtTaxonomy', 
  { 'foreign.tax_id' => 'self.tax_id' }); 

1;
