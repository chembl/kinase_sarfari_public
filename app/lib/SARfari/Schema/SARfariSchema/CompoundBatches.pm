package SARfari::Schema::SARfariSchema::CompoundBatches;
# $Id: CompoundBatches.pm 155 2009-08-25 11:02:39Z mdavies $

# SEE LICENSE

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");

__PACKAGE__->table("COMPOUND_BATCHES");

__PACKAGE__->add_columns(
    "cmpb_id",  { data_type => "NUMBER",  is_nullable => 0, size => undef },
    "sarregno", { data_type => "INTEGER", is_nullable => 0, size => undef },
    "source",   { data_type => "VARCHAR2",    is_nullable => 0, size => undef },
    "batch_id", { data_type => "INTEGER", is_nullable => 0, size => undef },
    "doc_id",   { data_type => "INTEGER", is_nullable => 0, size => undef },
);

__PACKAGE__->set_primary_key('cmpb_id');    

__PACKAGE__->belongs_to(
    star_doc => 'SARfari::Schema::SARfariSchema::StarliteDocuments',
    { 'foreign.doc_id' => 'self.doc_id' }
);

1;


