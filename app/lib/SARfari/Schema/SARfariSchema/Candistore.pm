package SARfari::Schema::SARfariSchema::Candistore;
# $Id: Candistore.pm 602 2010-04-12 09:50:59Z sarfari $

# SEE LICENSE

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");

__PACKAGE__->table("candistore");

__PACKAGE__->add_columns(
    "can_id",
    { data_type => "integer", is_nullable => 0, size => undef },
    "sarregno",
    { data_type => "integer", is_nullable => 0, size => undef },
    "usan_inn",
    { data_type => "varchar2", is_nullable => 0, size => undef },
    "usan_year",
    { data_type => "varchar2", is_nullable => 0, size => undef },
    "usan_stem",
    { data_type => "integer", is_nullable => 0, size => undef },
    "trade_name",
    { data_type => "varchar2", is_nullable => 0, size => undef },
    "atcc",
    { data_type => "varchar2", is_nullable => 0, size => undef },
    "highest_phase",
    { data_type => "varchar2", is_nullable => 0, size => undef },
    "approval_year_us",
    { data_type => "varchar2", is_nullable => 0, size => undef },
    "trade_name",
    { data_type => "varchar2", is_nullable => 0, size => undef },
    "highest_phase",
    { data_type => "varchar2", is_nullable => 0, size => undef },
    "mechanism_of_action",
    { data_type => "varchar2", is_nullable => 0, size => undef },
    "mechanism_of_action_modifier",
    { data_type => "varchar2", is_nullable => 0, size => undef },
    "prodrug_active_metabolite",
    { data_type => "varchar2", is_nullable => 0, size => undef },
    "company_id",
    { data_type => "varchar2", is_nullable => 0, size => undef },
);

__PACKAGE__->set_primary_key('can_id');

__PACKAGE__->belongs_to(
    mol => 'SARfari::Schema::SARfariSchema::CompoundMols',
    { 'foreign.sarregno' => 'self.sarregno' }    
);

__PACKAGE__->belongs_to(
    company => 'SARfari::Schema::SARfariSchema::CandistoreCompanies',
    { 'foreign.company_id' => 'self.company_id' }, { 'join_type' => 'left' } 
);

1;
