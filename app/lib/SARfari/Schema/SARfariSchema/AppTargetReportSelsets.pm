package SARfari::Schema::SARfariSchema::AppTargetReportSelsets;
# $Id: AppTargetReportSelsets.pm 155 2009-08-25 11:02:39Z mdavies $

# SEE LICENSE

use strict;
use base 'DBIx::Class';

__PACKAGE__->load_components(qw/ Core /);

__PACKAGE__->table('app_target_report_selsets');

__PACKAGE__->add_columns( 
  "dom_id",
  { data_type   => 'number', is_nullable => 0 },
  "ds_count",
  { data_type   => 'number', is_nullable => 0 },
  "nlpep_count",
  { data_type   => 'number', is_nullable => 0 },
  "nlpep_names",
  { data_type   => 'number', is_nullable => 0 },      
  "nlsmol_count",
  { data_type   => 'number', is_nullable => 0 },
  "nlsmol_names",
  { data_type   => 'number', is_nullable => 0 },
);

__PACKAGE__->set_primary_key('dom_id');

1;
