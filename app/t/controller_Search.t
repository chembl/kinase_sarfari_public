# $Id: controller_Search.t 151 2009-08-25 10:53:04Z mdavies $

# SEE LICENSE

use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'SARfari' }
BEGIN { use_ok 'SARfari::Controller::Search' }

ok( request('/search')->is_success, 'Request should succeed' );


