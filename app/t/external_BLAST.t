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
    use_ok( 'SARfari::External::BLAST::Simple' );
    require_ok( 'SARfari::External::BLAST::Simple' );
}

#Get some test files
Readonly my $FILE_PATTERN => "$FindBin::Bin/../t/external_BLAST.files/*.blast";
my @test_files =  glob($FILE_PATTERN);

SKIP: {
    skip "No test files found", if scalar(@test_files) < 1;
    
    foreach my $file(@test_files){
        my $blast_simple = SARfari::External::BLAST::Simple->new($file);
        isa_ok( $blast_simple, 'SARfari::External::BLAST::Simple');
        
        like($blast_simple->get_query_length, qr/\d+/, "Query length matched:".$blast_simple->get_query_length);
        
        while ( my $hit = $blast_simple->next ) {
        	ok(length($hit->get_name) > 0, "Query name matched: ".$hit->get_name);
        	like($hit->get_length, qr/\d+/, "Hit length matched: ".$hit->get_length);
        	
        	 while ( my $hsp = $hit->next ) {
        	 	like($hsp->get_identity, qr/\d+/, "HSP identity matched: ".$hsp->get_identity);       	 	
        	 }	
        }
    }
}


