package SARfari::Schema::SARfariSchema::CandistoreCompanies;
# $Id: CandistoreCompanies.pm 602 2010-04-12 09:50:59Z sarfari $

# SEE LICENSE

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");

__PACKAGE__->table("candistore_companies");

__PACKAGE__->add_columns(
    "company_id",
    { data_type => "integer", is_nullable => 0, size => undef },
    "company_name",
    { data_type => "varchar2", is_nullable => 0, size => undef },
);

__PACKAGE__->set_primary_key('company_id');

1;
