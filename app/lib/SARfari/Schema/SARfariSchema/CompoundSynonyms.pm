package SARfari::Schema::SARfariSchema::CompoundSynonyms;
# $Id: CompoundSynonyms.pm 155 2009-08-25 11:02:39Z mdavies $

# SEE LICENSE

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("COMPOUND_SYNONYMS");
__PACKAGE__->add_columns(
    "int_pk",
    { data_type => "INTEGER", is_nullable => 0, size => undef },
    "sarregno",
    { data_type => "INTEGER", is_nullable => 0, size => undef },
    "syn",
    { data_type => "TEXT", is_nullable => 0, size => undef },
    "syn_source",
    { data_type => "TEXT", is_nullable => 0, size => undef },
);

__PACKAGE__->set_primary_key('int_pk');    

1;
