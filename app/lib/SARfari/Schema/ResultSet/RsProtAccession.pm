package SARfari::Schema::ResultSet::RsProtAccession;
# $Id: RsProtAccession.pm 164 2009-08-25 13:57:22Z mdavies $

# SEE LICENSE

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use Carp;
use Data::Dumper;

sub getAccessionDetails{
	my ( $self, $domids, $params ) = @_;
	
	my $rows;
        
    eval {
        $rows = [
            $self->search(
                {'me.accession_source' => ['SWISSPROT','TREMBL']},
                {   
                	select => ['dom_id', 'accession', 'accession_source'],
                }
                )->search_literal(
                " me.dom_id in (" . join( ', ', @{$domids} ) . ") "
                )->cursor->all
        ];
    };

    # Pass exception up the chain
    if ($@) {
        croak($@);
    }

	my $acc_details = {};
    foreach my $row (@{$rows}){
    	push(@{$acc_details->{$row->[0]}}, { 'accession' => $row->[1], 'source' => $row->[2]});
    }
    
    return $acc_details;
}

1;
