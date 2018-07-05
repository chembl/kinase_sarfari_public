package SARfari::Schema::SARfariSchema::AppTargetReportBio;
# $Id: AppTargetReportBio.pm 155 2009-08-25 11:02:39Z mdavies $

# SEE LICENSE

use strict;
use base 'DBIx::Class';


__PACKAGE__->load_components(qw/ Core /);

__PACKAGE__->table('app_target_report_bio');

__PACKAGE__->add_columns( 
  "dom_id",
  { data_type   => 'number', is_nullable => 0 },
  "bio_all",
  { data_type   => 'number', is_nullable => 0 },
  "bio_ic50",
  { data_type   => 'number', is_nullable => 0 },  
  "bio_ki",
  { data_type   => 'number', is_nullable => 0 },
  "bio_pa2",
  { data_type   => 'number', is_nullable => 0 },  
  "bio_star_all",
  { data_type   => 'number', is_nullable => 0 },
  "bio_star_ic50",
  { data_type   => 'number', is_nullable => 0 },  
  "bio_star_ki",
  { data_type   => 'number', is_nullable => 0 },
  "bio_star_pa2",
  { data_type   => 'number', is_nullable => 0 }  
);

__PACKAGE__->set_primary_key('dom_id');

1;
