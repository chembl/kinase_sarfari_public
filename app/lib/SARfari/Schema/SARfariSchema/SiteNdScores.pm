package SARfari::Schema::SARfariSchema::SiteNdScores;
# $Id: SiteNdScores.pm 155 2009-08-25 11:02:39Z mdavies $

# SEE LICENSE

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");

__PACKAGE__->table("SITE_ND_SCORES");    

__PACKAGE__->add_columns(
    "dom_id",   { data_type => "integer", is_nullable => 0, size => undef },
    "site",     { data_type => "integer", is_nullable => 0, size => undef },
    "nd_score", { data_type => "integer", is_nullable => 0, size => undef },
);

1;
