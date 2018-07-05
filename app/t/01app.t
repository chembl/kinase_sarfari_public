# $Id: 01app.t 151 2009-08-25 10:53:04Z mdavies $

# SEE LICENSE

use strict;
use warnings;
use Test::More tests => 2;

BEGIN { use_ok 'Catalyst::Test', 'SARfari' }

ok( request('/')->is_success, 'Request should succeed' );
