package SARfari::Schema::SARfariSchema::ProtClassification;
# $Id: ProtClassification.pm 155 2009-08-25 11:02:39Z mdavies $

# SEE LICENSE

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");

__PACKAGE__->table("PROT_CLASSIFICATION");

__PACKAGE__->add_columns(
    "homologue_id",
    { data_type => "INTEGER", is_nullable => 0, size => undef },
    "level2",
    { data_type => "VARCHAR2", is_nullable => 0, size => undef },
    "level3",
    { data_type => "VARCHAR2", is_nullable => 0, size => undef },
    "level4",    
    { data_type => "VARCHAR2", is_nullable => 0, size => undef },
);

__PACKAGE__->set_primary_key('homologue_id');

1;
