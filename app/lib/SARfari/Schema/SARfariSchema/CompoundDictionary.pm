package SARfari::Schema::SARfariSchema::CompoundDictionary;
# $Id: CompoundDictionary.pm 239 2009-10-07 15:16:20Z mdavies $

# SEE LICENSE

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");

__PACKAGE__->table("COMPOUND_DICTIONARY");

__PACKAGE__->resultset_class('SARfari::Schema::ResultSet::RsCompoundDictionary');

__PACKAGE__->add_columns(
    "sarregno",
    { data_type => "INTEGER", is_nullable => 0, size => undef },
    "parent_sarregno",
    { data_type => "INTEGER", is_nullable => 0, size => undef },
    "starlite",
    { data_type => "NUMBER", is_nullable => 0, size => undef },
    "drugstore",
    { data_type => "NUMBER", is_nullable => 0, size => undef },
    "candistore",
    { data_type => "NUMBER", is_nullable => 0, size => undef },
    "virtual",
    { data_type => "NUMBER", is_nullable => 0, size => undef },
    "idmaps",
    { data_type => "VARCHAR2", is_nullable => 0, size => undef },
    "synonyms",
    { data_type => "VARCHAR2", is_nullable => 0, size => undef },
    "sources",
    { data_type => "VARCHAR2", is_nullable => 0, size => undef }    
);

__PACKAGE__->set_primary_key('sarregno');

__PACKAGE__->belongs_to(
    property => 'SARfari::Schema::SARfariSchema::CompoundProperties',
    { 'foreign.sarregno' => 'self.sarregno' }, { 'join_type' => 'left' }
);

__PACKAGE__->belongs_to(
    mol => 'SARfari::Schema::SARfariSchema::CompoundMols',
    { 'foreign.sarregno' => 'self.sarregno' }
);

__PACKAGE__->belongs_to(
    comp_bio_report => 'SARfari::Schema::SARfariSchema::CompoundMols',
    { 'foreign.sarregno' => 'self.sarregno' }
);

__PACKAGE__->has_many(
    batches => 'SARfari::Schema::SARfariSchema::CompoundBatches',
    { 'foreign.sarregno' => 'self.sarregno' }
);

__PACKAGE__->has_many(
    synonyms => 'SARfari::Schema::SARfariSchema::CompoundSynonyms',
    { 'foreign.sarregno' => 'self.sarregno' },
    { 'join_type'        => 'left' }             
);

__PACKAGE__->has_many(
    idmaps => 'SARfari::Schema::SARfariSchema::CompoundIdmaps',
    { 'foreign.sarregno' => 'self.sarregno' }
);

__PACKAGE__->has_many(
    act2dom => 'SARfari::Schema::SARfariSchema::ActivitiesToDomains',
    { 'foreign.sarregno' => 'self.sarregno' }
);

1;

