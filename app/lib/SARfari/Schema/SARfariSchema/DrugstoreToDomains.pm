package SARfari::Schema::SARfariSchema::DrugstoreToDomains;
# $Id: DrugstoreToDomains.pm 239 2009-10-07 15:16:20Z mdavies $

# SEE LICENSE

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");

__PACKAGE__->table("drugstore_to_domains");    

__PACKAGE__->add_columns(
    "sarregno", { data_type => "integer", is_nullable => 0, size => undef },
    "dom_id",   { data_type => "integer", is_nullable => 0, size => undef }
);

__PACKAGE__->set_primary_key( 'sarregno', 'dom_id' );

__PACKAGE__->belongs_to(
    mol => 'SARfari::Schema::SARfariSchema::CompoundMols',
    { 'foreign.sarregno' => 'self.sarregno' }
);

__PACKAGE__->has_many(
    synonyms => 'SARfari::Schema::SARfariSchema::CompoundSynonyms',
    { 'foreign.sarregno' => 'self.sarregno' },
    { 'join_type'        => 'left' }
);

__PACKAGE__->belongs_to(
    domain => 'SARfari::Schema::SARfariSchema::ProtDomain',
    { 'foreign.dom_id' => 'self.dom_id' }
);

1;
