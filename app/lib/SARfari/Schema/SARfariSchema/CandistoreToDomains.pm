package SARfari::Schema::SARfariSchema::CandistoreToDomains;
# $Id: CandistoreToDomains.pm 602 2010-04-12 09:50:59Z sarfari $

# SEE LICENSE

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");

__PACKAGE__->table("candistore_to_domains");

__PACKAGE__->add_columns(
    "int_pk", { data_type => "integer",  is_nullable => 0, size => undef },
    "can_id", { data_type => "integer",  is_nullable => 0, size => undef },
    "target", { data_type => "varchar2",  is_nullable => 0, size => undef },
    "tid", { data_type => "integer", is_nullable => 0, size => undef },
    "dom_id", { data_type => "integer", is_nullable => 0, size => undef },
    "association_id", { data_type => "integer", is_nullable => 0, size => undef },
);

__PACKAGE__->set_primary_key('int_pk');

__PACKAGE__->belongs_to(
    candi => 'SARfari::Schema::SARfariSchema::Candistore',
    { 'foreign.can_id' => 'self.can_id' }
);

__PACKAGE__->belongs_to(
    domain => 'SARfari::Schema::SARfariSchema::ProtDomain',
    { 'foreign.dom_id' => 'self.dom_id' }
);

1;
