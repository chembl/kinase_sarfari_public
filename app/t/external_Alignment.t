# $Id: external_Alignment.t 151 2009-08-25 10:53:04Z mdavies $

# SEE LICENSE

use strict;
use warnings;
use Test::More qw( no_plan );
use Test::Exception;
use Readonly;

use FindBin;
use lib "$FindBin::Bin/../lib/";

BEGIN {     
    use_ok( 'SARfari::External::Alignment::Simple' );
    require_ok( 'SARfari::External::Alignment::Simple' );
}

#Check methods can be accessed
can_ok('SARfari::External::Alignment::Simple',
    qw( new next iterator_reset count display ));

__END__

#Get some test files
Readonly my $FILE_PATTERN => '../t/02.alignment.files/*.out';
my @test_files =  glob($FILE_PATTERN);

SKIP: {
    skip "No test files found", if scalar(@test_files) < 1;

    foreach my $file(@test_files){
        my $aln_file_obj = Chematica::Alignment::Parse->new($file);
        isa_ok( $aln_file_obj, 'Chematica::Alignment::Parse');

        # Check sequence count returned
        like($aln_file_obj->count, qr/\d+/, 'Sequence count is a number');
        ok($aln_file_obj->count > 0,  'Sequence count number is greater than 0');

        # Check non-existent fasta cause module to through error
        my $SEQ_COUNT       = $aln_file_obj->count;
        my $SEQ_COUNT_PLUS1 = $aln_file_obj->count + 1;

        ok($aln_file_obj->get_seq_at($SEQ_COUNT), "Aln seq at position $SEQ_COUNT found");
        dies_ok{$aln_file_obj->get_seq_at($SEQ_COUNT_PLUS1)} "Aln seq at position $SEQ_COUNT_PLUS1 not found";

        dies_ok{$aln_file_obj->get_seq_at(0)} 'Aln seq at position 0 not found';
        dies_ok{$aln_file_obj->get_seq_at(-1)} 'Aln seq at position -1 not found';
        dies_ok{$aln_file_obj->get_seq_at(99)} 'Aln seq at position 99 not found';

        my $i = 0;

        while(my $aln_obj = $aln_file_obj->next){
            $i++;

            #Check get_seq_at is working correctly
            like($aln_obj->get_seq, qr/[a-zA-Z-]+/, "$file sequence $i matches [a-zA-Z-]");
            is($aln_obj->get_seq,$aln_file_obj->get_seq_at($i)->get_seq, "Get aln seq at position $i matched current aln seq");
        }
    }
}


#!/usr/local/bin/perl -w
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
