package SARfari::Schema::ResultSet::RsX3dLigandToPdb;
# $Id: RsX3dLigandToPdb.pm 526 2010-01-22 13:33:18Z mdavies $

# SEE LICENSE

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use Carp;
use Data::Dumper;

sub getPdbLigands {

    my ( $self, $query ) = @_;

    my @ligands;

    eval {
        @ligands= $self->all;
    };

    # Pass exception up the chain
    if ($@) {
        croak($@);
    }
    
    my $pdb_ligands = {};
    
    foreach my $lig (@ligands){
    	push(@{$pdb_ligands->{$lig->sunid_px}}, {het_code=> $lig->het_code, sarregno => $lig->sarregno});
    } 

    return $pdb_ligands;
}

sub pdbligToPx {

    my ( $self, $query ) = @_;

    my $pxs;

    eval {

        $pxs = [
            map { $_->[0] }
                $self->search( 
                	{'me.sarregno' => $query}, 
                	{ select => [qw / me.sunid_px /], } 
                )->cursor->all
        ];
    };

    # Pass exception up the chain
    if ($@) {
        croak($@);
    }

    return $pxs;
}

1;
