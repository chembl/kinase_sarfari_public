package SARfari::Schema::SARfariSchema::Alignment;
# $Id: Alignment.pm 155 2009-08-25 11:02:39Z mdavies $

# SEE LICENSE

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");

__PACKAGE__->table("ALIGNMENT");

__PACKAGE__->resultset_class('SARfari::Schema::ResultSet::RsAlignment');

__PACKAGE__->add_columns(
    "dom_id",
    { data_type => "NUMBER", is_nullable => 0, size => undef },
    "aln",
    { data_type => "VARCHAR2", is_nullable => 0, size => undef },
    "aln_ungapped",
    { data_type => "VARCHAR2", is_nullable => 0, size => undef },
    "sequence",
    { data_type => "VARCHAR2", is_nullable => 0, size => undef },
    "md5",
    { data_type => "VARCHAR2", is_nullable => 0, size => undef },    
);

__PACKAGE__->set_primary_key('dom_id');

__PACKAGE__->belongs_to( domain => 'SARfari::Schema::SARfariSchema::ProtDomain', 
  { 'foreign.dom_id' => 'self.dom_id' });
  
1;
