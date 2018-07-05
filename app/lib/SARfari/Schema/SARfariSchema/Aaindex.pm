package SARfari::Schema::SARfariSchema::Aaindex;
# $Id: Aaindex.pm 155 2009-08-25 11:02:39Z mdavies $

# SEE LICENSE

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");

__PACKAGE__->table("AAINDEX");

__PACKAGE__->add_columns(    
    "aaindex_id",
    { data_type => "TEXT", is_nullable => 0, size => undef },
    "description",
    { data_type => "TEXT", is_nullable => 0, size => undef },
    "litdb",
    { data_type => "TEXT", is_nullable => 0, size => undef },
    "pubmed",
    { data_type => "NUMBER", is_nullable => 0, size => undef },
);

__PACKAGE__->set_primary_key('aaindex_id');

1;
