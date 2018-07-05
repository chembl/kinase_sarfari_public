# $Id: 02pod.t 151 2009-08-25 10:53:04Z mdavies $

# SEE LICENSE

use strict;
use warnings;
use Test::More;

eval "use Test::Pod 1.14";
plan skip_all => 'Test::Pod 1.14 required' if $@;
plan skip_all => 'set TEST_POD to enable this test' unless $ENV{TEST_POD};

all_pod_files_ok();
