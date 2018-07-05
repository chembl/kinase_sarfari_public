package SARfari::Schema::SARfariSchema::AlignmentPositions;
# $Id: AlignmentPositions.pm 155 2009-08-25 11:02:39Z mdavies $

# SEE LICENSE

use strict;    
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");

__PACKAGE__->table("ALIGNMENT_POSITIONS");

__PACKAGE__->add_columns(
    "dom_id",  { data_type => "integer", is_nullable => 0, size => undef },
    "aln_pos", { data_type => "integer", is_nullable => 0, size => undef },
    "seq_pos", { data_type => "integer", is_nullable => 0, size => undef },
    "residue", { data_type => "varchar2",   is_nullable => 0, size => undef },
);

__PACKAGE__->set_primary_key('dom_id','aln_pos');   

__PACKAGE__->belongs_to( domain => 'SARfari::Schema::SARfariSchema::ProtDomain', 
  { 'foreign.dom_id' => 'self.dom_id' });  

1;
