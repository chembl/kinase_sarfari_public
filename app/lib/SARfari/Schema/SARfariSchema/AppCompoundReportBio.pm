package SARfari::Schema::SARfariSchema::AppCompoundReportBio;
# $Id: AppCompoundReportBio.pm 155 2009-08-25 11:02:39Z mdavies $

# SEE LICENSE

use strict;
use base 'DBIx::Class';


__PACKAGE__->load_components(qw/ Core /);

__PACKAGE__->table('app_compound_report_bio');

__PACKAGE__->add_columns( 
  "sarregno",
  { data_type   => 'integer', is_nullable => 0 },
  "bio_all",
  { data_type   => 'number', is_nullable => 0 },
  "bio_ic50",
  { data_type   => 'number', is_nullable => 0 },  
  "bio_ki",
  { data_type   => 'number', is_nullable => 0 },
  "bio_pa2",
  { data_type   => 'number', is_nullable => 0 },  
  "func_all",
  { data_type   => 'number', is_nullable => 0 },
  "admet_thalf",
  { data_type   => 'number', is_nullable => 0 },  
  "admet_f",
  { data_type   => 'number', is_nullable => 0 },
  "admet_all",
  { data_type   => 'number', is_nullable => 0 }  
);

__PACKAGE__->set_primary_key('sarregno');

1;
