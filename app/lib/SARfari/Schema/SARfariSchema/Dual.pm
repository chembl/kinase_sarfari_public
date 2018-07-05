package SARfari::Schema::SARfariSchema::Dual;
# $Id: Dual.pm 155 2009-08-25 11:02:39Z mdavies $

# SEE LICENSE

use strict;
use base 'DBIx::Class';
use Data::Dumper;

__PACKAGE__->load_components(qw/ Core /);

__PACKAGE__->table('dual');

__PACKAGE__->resultset_class('SARfari::Schema::ResultSet::RsDual');

1;
