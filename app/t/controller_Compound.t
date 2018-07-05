# $Id: controller_Compound.t 151 2009-08-25 10:53:04Z mdavies $

# SEE LICENSE

use strict;
use warnings;
use Test::More 'no_plan';
use FindBin;
use lib "$FindBin::Bin/../";

BEGIN { use_ok 'Catalyst::Test', 'SARfari' }
BEGIN { use_ok 'SARfari::Controller::Compound' }

#ok( request('/compound')->is_success, 'Request should succeed' );

use ok "Test::WWW::Mechanize::Catalyst" => "SARfari";

# Mech user
my $mech = Test::WWW::Mechanize::Catalyst->new;

# Check homepage returns 2xx status
$mech->get_ok( "http://localhost/", "Homepage found" );

# Check homepage returns 2xx status
$mech->get_ok( "http://localhost/compound", "Compound Homepage found" );

# Test compound searches
# 1. Substructure search
$mech->submit_form(
    form_name => 'chimeform',
    fields    => {
        chime      => qw/ ZYQLX2yAmBwQCWKJWj8X3bgveEwaRWdEDI4A2P^tnUNtSsp$HhMXYdE1CjNmsC1Vd7rl4qoAI17QuZhuw2cps4WxBTwzu6PBSSWgew1b95Z$JZ1u4uEH7NTcS06P8hCuKKxRHX3iuvegD5fjP1F^Olui22U4HqQO5IGlkgOvzEUBqZPpeiEU8J69noNJFdONEIyWma1jjULKHNi25FrVN4jy4J59dGlMkr3SFiNMcQUuTbfi1lrmDXNY5ZzyiVp0m9cchjHko0j1LYbWSD0XeexpJgboTB6Jcjc^qQ3krStmHhpXo7mQfZtvqNaZ03XrV5BAD207YUo6h7SC88GxhjQJp6AZIgeexgoXKVZRkg^Tyjv$yz$fzs8CSfN /,
        query_type => 'Substructure'    
    }
);

unless ($mech->success){
    die "Can't submit chimeform form for substructure search: ", $mech->response->status_line."\n";
}

#TODO: Should return results 


$mech->back();

# 2. Flexmatch search
$mech->submit_form(
    form_name => 'chimeform',
    fields    => {
        chime      => 'ZYQLX2yAmBwQCWKJWj8X3bgveEwaRWdEDI4A2P^tnUNtSsp$HhMXYdE1CjNmsC1Vd7rl4qoAI17QuZhuw2cps4WxBTwzu6PBSSWgew1b95Z$JZ1u4uEH7NTcS06P8hCuKKxRHX3iuvegD5fjP1F^Olui22U4HqQO5IGlkgOvzEUBqZPpeiEU8J69noNJFdONEIyWma1jjULKHNi25FrVN4jy4J59dGlMkr3SFiNMcQUuTbfi1lrmDXNY5ZzyiVp0m9cchjHko0j1LYbWSD0XeexpJgboTB6Jcjc^qQ3krStmHhpXo7mQfZtvqNaZ03XrV5BAD207YUo6h7SC88GxhjQJp6AZIgeexgoXKVZRkg^Tyjv$yz$fzs8CSfN',
        query_type => 'Flexmatch'    
    }
);

unless ($mech->success){
    die "Can't submit chimeform form for flexmatch search: ", $mech->response->status_line."\n";
}

#TODO: Should return results 


$mech->back();

# 3. Similarity search
$mech->submit_form(
    form_name => 'chimeform',
    fields    => {
        chime      => 'ZYQLX2yAmBwQCWKJWj8X3bgveEwaRWdEDI4A2P^tnUNtSsp$HhMXYdE1CjNmsC1Vd7rl4qoAI17QuZhuw2cps4WxBTwzu6PBSSWgew1b95Z$JZ1u4uEH7NTcS06P8hCuKKxRHX3iuvegD5fjP1F^Olui22U4HqQO5IGlkgOvzEUBqZPpeiEU8J69noNJFdONEIyWma1jjULKHNi25FrVN4jy4J59dGlMkr3SFiNMcQUuTbfi1lrmDXNY5ZzyiVp0m9cchjHko0j1LYbWSD0XeexpJgboTB6Jcjc^qQ3krStmHhpXo7mQfZtvqNaZ03XrV5BAD207YUo6h7SC88GxhjQJp6AZIgeexgoXKVZRkg^Tyjv$yz$fzs8CSfN',
        query_type => 'Similarity',
        cut_off    => 95    
    }
);

unless ($mech->success){
    die "Can't submit chimeform form for similarity search: ", $mech->response->status_line."\n";
}    

#TODO: Should return results 
