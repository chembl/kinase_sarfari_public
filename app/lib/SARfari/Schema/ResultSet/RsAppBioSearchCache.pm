package SARfari::Schema::ResultSet::RsAppBioSearchCache;
# $Id: RsAppBioSearchCache.pm 526 2010-01-22 13:33:18Z mdavies $

# SEE LICENSE
use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use Carp;
use Data::Dumper;

sub get_job_column_data {
    my ( $self, $jobid, $col ) = @_;

    my $data;

    eval {
        $data = [
            map { $_->[0] } $self->search(
               { 'me.job_id' => $jobid },
               { select => [{distinct => $col}]}
            )->cursor->all
        ];    
    };

    # Pass exception up the chain
    if ($@) {
        croak($@);
    }
    
    return $data;
}

1;
