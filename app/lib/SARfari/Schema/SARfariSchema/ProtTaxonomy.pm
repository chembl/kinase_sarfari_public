package SARfari::Schema::SARfariSchema::ProtTaxonomy;
# $Id: ProtTaxonomy.pm 155 2009-08-25 11:02:39Z mdavies $

# SEE LICENSE

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");

__PACKAGE__->table("PROT_TAXONOMY");

__PACKAGE__->add_columns(
    "organism",
    { data_type => "varchar2", is_nullable => 0, size => undef },
    "common_name",
    { data_type => "varchar2", is_nullable => 0, size => undef },
    "tax_id",
    { data_type => "integer", is_nullable => 0, size => undef },
    "tax_code",
    { data_type => "varchar2", is_nullable => 0, size => undef },
    "tax_prefix",
    { data_type => "varchar2", is_nullable => 0, size => undef },
);

__PACKAGE__->set_primary_key('tax_id');
     
1;
