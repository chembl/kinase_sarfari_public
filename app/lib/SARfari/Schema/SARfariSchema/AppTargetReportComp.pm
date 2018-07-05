package SARfari::Schema::SARfariSchema::AppTargetReportComp;
# $Id: AppTargetReportComp.pm 155 2009-08-25 11:02:39Z mdavies $

# SEE LICENSE

use strict;
use base 'DBIx::Class';

__PACKAGE__->load_components(qw/ Core /);

__PACKAGE__->table('app_target_report_comp');

__PACKAGE__->add_columns( 
  "dom_id",
  { data_type   => 'number', is_nullable => 0 },
  "comp_all",
  { data_type   => 'number', is_nullable => 0 },
  "comp_ic50_cut",
  { data_type   => 'number', is_nullable => 0 },
  "comp_ki_cut",
  { data_type   => 'number', is_nullable => 0 },      
  "comp_star_all",
  { data_type   => 'number', is_nullable => 0 },
  "comp_star_ic50_cut",
  { data_type   => 'number', is_nullable => 0 },
  "comp_star_ki_cut",
  { data_type   => 'number', is_nullable => 0 }      
);

__PACKAGE__->set_primary_key('dom_id');

1;
