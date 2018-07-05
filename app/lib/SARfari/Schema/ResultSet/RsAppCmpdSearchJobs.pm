package SARfari::Schema::ResultSet::RsAppCmpdSearchJobs;
# $Id: RsAppCmpdSearchJobs.pm 376 2009-11-10 11:31:10Z mdavies $

# SEE LICENSE

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use Carp;

sub cached_query {
    my ( $self, $chime_inchikey, $query_type ) = @_;

    my $query;

    eval {
        $query = $self->search({
           'me.chime_string_md5' => $chime_inchikey,
           'me.query_type'       => $query_type,
        })->search_literal('me.chime_string_md5 IS NOT NULL')->first;    
    };

    # Pass exception up the chain
    if ($@) {
        croak($@);
    }
    
    # Got a match return jobid
    if($query){
        return $query->job_id;
    }
    
    # No pre cached results - just return
    return;
}

1;
