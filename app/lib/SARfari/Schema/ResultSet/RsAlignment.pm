package SARfari::Schema::ResultSet::RsAlignment;
# $Id: RsAlignment.pm 155 2009-08-25 11:02:39Z mdavies $

# SEE LICENSE

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use Carp;
use Data::Dumper;

sub fasta {
    my ( $self, $domids ) = @_;

    my $details;

    eval {
        $details = [
            $self->search(
                undef,
                {   select => [ 'domain.display_name', 'me.sequence' ],
                    join   => ['domain'],
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

    my $fasta_aref =
        [ map { ">" . $_->[0] . "\n" . $_->[1] . "\n" } @{$details} ];

    return $fasta_aref;
}

sub aln {
    my ( $self, $domids ) = @_;

    my $details;

    eval {
        $details = [
            $self->search(
                undef,
                {   select => [ 'domain.display_name', 'me.aln' ],
                    join   => [ 'domain' ],
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

    my $aln_aref = [ map { $_->[0] . "\t" . $_->[1] . "\n" } @{$details} ];

    return $aln_aref;
}

1;
