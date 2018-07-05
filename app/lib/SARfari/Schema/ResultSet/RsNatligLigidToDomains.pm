package SARfari::Schema::ResultSet::RsNatligLigidToDomains;
# $Id: RsNatligLigidToDomains.pm 155 2009-08-25 11:02:39Z mdavies $

# SEE LICENSE

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use Carp;
use Data::Dumper;

# Convert synonym to regno

sub synToRegno {

    my ( $self, $query ) = @_;

    my $regnos;

    eval {

        $regnos = [
            map { $_->[0] } $self->search(
                undef,
                {   select => [qw / me.sarregno /],
                    join   => [qw / synonyms /]
                }
                )->search_literal(
                " synonyms.syn like \'%" . uc($query) . "%\' "
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