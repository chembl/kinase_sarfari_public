package SARfari::Schema::ResultSet::RsAppSearchTargetCache;
# $Id: RsAppSearchTargetCache.pm 155 2009-08-25 11:02:39Z mdavies $

# SEE LICENSE

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use Carp;

sub get_compounds {
    my ( $self, $jobid, $filter ) = @_;
    
    my $regnos;
    
    eval {
        my $tmp_rs = $self->search(
            { 'me.job_id' => $jobid },
            {   select => [qw / act2dom.sarregno /],
                join   => [qw / act2dom /]
            }
         );
         
         $regnos = [ map { $_->[0] }
                     ($filter)
                      ?  $tmp_rs->search_literal($filter)->cursor->all 
                      :  $tmp_rs->cursor->all ]; 
    };

    # Pass exception up the chain
    if ($@) {
        croak($@);
    }
    
    return $regnos;
}

1;
