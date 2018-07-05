package SARfari::Schema::SARfariSchema::AppCounts;
# $Id: AppCounts.pm 567 2010-02-19 11:32:05Z mdavies $

# SEE LICENSE

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");

__PACKAGE__->table("app_counts");

__PACKAGE__->add_columns(
    "display_order",
    { data_type => "INTEGER", is_nullable => 0, size => undef },
    "display_name",
    { data_type => "INTEGER", is_nullable => 0, size => undef },
    "data_count",
    { data_type => "INTEGER", is_nullable => 0, size => undef },    
);

__PACKAGE__->set_primary_key("display_order");

1;
