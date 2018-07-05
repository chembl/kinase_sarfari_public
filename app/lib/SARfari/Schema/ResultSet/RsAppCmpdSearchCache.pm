package SARfari::Schema::ResultSet::RsAppCmpdSearchCache;
# $Id: RsAppCmpdSearchCache.pm 155 2009-08-25 11:02:39Z mdavies $

# SEE LICENSE
use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use Carp;
use Data::Dumper;

sub get_job_compounds {
    my ( $self, $jobid ) = @_;

    my $regnos;

    eval {
        $regnos = [
            map { $_->[0] } $self->search(
               { 'me.job_id' => $jobid },
               { select => [qw/ sarregno /]}
            )->cursor->all
        ];    
    };

    # Pass exception up the chain
    if ($@) {
        croak($@);
    }
    
    return $regnos;
}

1;
