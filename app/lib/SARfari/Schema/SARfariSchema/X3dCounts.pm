package SARfari::Schema::SARfariSchema::X3dCounts;
# $Id: X3dCounts.pm 155 2009-08-25 11:02:39Z mdavies $

# SEE LICENSE

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");

__PACKAGE__->table('x3d_counts');

__PACKAGE__->add_columns(
    "sunid_px",         { data_type => 'integer', is_nullable => 1 },
    "dom_id",           { data_type => 'integer', is_nullable => 1 },
    "transcript",       { data_type => 'integer', is_nullable => 1 },
    "gene_domain_name", { data_type => 'integer', is_nullable => 1 },
    "bio_all",          { data_type => 'integer', is_nullable => 1 },
    "comp_all",         { data_type => 'integer', is_nullable => 1 },
    "ds_count",         { data_type => 'integer', is_nullable => 1 } 
);

__PACKAGE__->set_primary_key('sunid_px');

1;
