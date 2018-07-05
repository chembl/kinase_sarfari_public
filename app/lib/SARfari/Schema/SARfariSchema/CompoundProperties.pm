package SARfari::Schema::SARfariSchema::CompoundProperties;
# $Id: CompoundProperties.pm 155 2009-08-25 11:02:39Z mdavies $

# SEE LICENSE

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");

__PACKAGE__->table("COMPOUND_PROPERTIES");

__PACKAGE__->add_columns(
    "sarregno",
    { data_type => "INTEGER", is_nullable => 0, size => undef },
    "mw_freebase",
    { data_type => "NUMBER", is_nullable => 0, size => undef },
    "alogp",
    { data_type => "NUMBER", is_nullable => 0, size => undef },
    "hba",
    { data_type => "INTEGER", is_nullable => 0, size => undef },
    "hbd",
    { data_type => "INTEGER", is_nullable => 0, size => undef },
    "psa",
    { data_type => "NUMBER", is_nullable => 0, size => undef },
    "rtb",
    { data_type => "INTEGER", is_nullable => 0, size => undef },
    "ro3_pass",
    { data_type => "TEXT", is_nullable => 0, size => undef },
    "num_ro5_violations",
    { data_type => "TEXT", is_nullable => 0, size => undef },
    "med_chem_friendly",
    { data_type => "TEXT", is_nullable => 0, size => undef },
    "mol_id",    
    { data_type => "INTEGER", is_nullable => 0, size => undef },
);

__PACKAGE__->set_primary_key('sarregno');

1;
