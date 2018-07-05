package SARfari::External::Alignment::Simple;
# $Id: Simple.pm 175 2009-08-26 13:39:38Z mdavies $

# SEE LICENSE

use strict;
use Carp;
use Data::Dumper;
use SARfari::External::Sequence::Simple;

sub new {
    my $class = shift;

    my $self = bless {}, $class;

    $self->{input}     = shift;
    $self->{site_name} = shift;
    $self->{sites}     = shift;
    $self->{parsed}    = undef;
    $self->{iterator}  = 0;
    $self->{aln_len}   = 0;
    $self->{id_length} =
        ( length( $self->{site_name} ) > 10 )
        ? length( $self->{site_name} )
        : 10;    
    
    $self->{site_name} =~ s/\s/\_/g;
    
    $self->{data} = $self->_parse_aln( $self->{aln_file} );

    $self->{ids} = [ sort ( keys %{ $self->{data} } ) ];

    $self->{gaps} = $self->_get_gaps( $self->{aln_file} );

    $self->{positions} = $self->_create_aln_positions( $self->{aln_len} );

    $self->{site_positions} =
        $self->_create_site_positions( $self->{sites}, $self->{aln_len} );

    return $self;
}

# Get next seq in alignment

sub next {
    my $self = shift;

    if ( $self->{iterator} == scalar( @{ $self->{ids} } ) ) {
        $self->{iterator} = 0;
        return undef;
    }

    my $key = $self->{ids}->[ $self->{iterator} ];
    my $val = $self->{data}->{$key};

    $self->{iterator}++;

    return SARfari::External::Sequence::Simple->new( $key, $val );
}

# Reset iterator counter

sub iterator_reset {
    my $self = shift;
    $self->{iterator} = 0;
}

# Get number of sequences in alignment

sub count {
    my $self = shift;
    return scalar( @{ $self->{ids} } );
}

# Get printable version of alignment

sub display {
    my $self = shift;
    my $display;

    # Binding site positions
    my @tmp = @{ $self->{site_positions} };
    delete @tmp[ @{ $self->{gaps} } ];
    $display .=
        sprintf( "%-" . $self->{id_length} . "s", $self->{site_name} ) . " "
        . join( '', grep {$_} @tmp ) . "\n";

    # Residue counter positions
    for my $key ( reverse sort keys %{ $self->{positions} } ) {
        @tmp = @{ $self->{positions}->{$key} };
        delete @tmp[ @{ $self->{gaps} } ];
        $display .=
            sprintf( "%-" . $self->{id_length} . "s", $key ) . " "
            . join( '', grep {$_} @tmp ) . "\n";
    }

    # Change * back to 0, see _create_aln_positions
    $display =~ s/\*/0/g;

    # Just in case
    $self->iterator_reset;

    while ( my $s = $self->next ) {
        @tmp = split( //, $s->get_seq );
        delete @tmp[ @{ $self->{gaps} } ];
        $display .=
            sprintf( "%-" . $self->{id_length} . "s", $s->get_id ) . " "
            . join( '', grep {$_} @tmp ) . "\n";
    }

    return $display;
}

# Internal method used to parse alignment

sub _parse_aln {
    my $self    = shift;
    my @tmp_aln = split( /\n/, $self->{input} );

    my $href = {};

    foreach my $line (@tmp_aln) {

        next, if ( $line =~ /clustal/i );
        next, if ( $line =~ /^\s*$/ );
        next, if ( $line =~ /^\s+[\*|\.|:]/ );

        $line =~ s/\n//g;

        my @details = split( /\s+/, $line );

        if ( scalar(@details) > 2 ) {
            croak(
                "Sequence in alignment contains more with space than expected:\n $line"
            );
        }

        if ( !$href->{ $details[0] } ) {
            $href->{ $details[0] } = $details[1];
        }
        else {
            $href->{ $details[0] } .= $details[1];
        }

        #For printing purposes make sure id_length is set of to longest id
        if ( length( $details[0] ) > $self->{id_length} ) {
            $self->{id_length} = length( $details[0] );
        }
    }

    croak("Alignment format error"), if ( $self->_check_aln($href) );

    #print Dumper $href;

    return $href;
}

# Internal method used to sanity check alignment

sub _check_aln {
    my $self = shift;
    my $aln  = shift;

    my @ids = keys %{$aln};
    my $len = length( $aln->{ $ids[0] } );

    foreach my $id (@ids) {
        if ( length( $aln->{$id} ) != $len ) {
            print "Memeber: $id\n"
                . "Expected length: $len\n"
                . "Found length: "
                . length( $aln->{$id} ) . "\n";
            return 1;
        }
    }

    $self->{aln_len} = $len;

    return undef;
}

# Get positions of fully gapped columns

sub _get_gaps {
    my $self = shift;

    # Return structure
    my $gaps = [];

    # Get first sequence
    my $first_seq = $self->next;
    $self->iterator_reset;

RESIDUE:
    for ( my $i = 0; $i < $self->{aln_len}; $i++ ) {

        # Avoid going into for loop if first sequence is non-gapped
        if ( substr( $first_seq->get_seq, $i, 1 ) ne '-' ) {
            next;
        }

        my $j = 0;    # residue in column counter
        while ( my $s = $self->next ) {
            $j++;

            my $seq = $s->get_seq;

            # Break loop if any sequence contains a non-gapped column
            if ( substr( $seq, $i, 1 ) ne "-" ) {
                $self->iterator_reset;    # Important
                next RESIDUE;
            }

         # Completely gapped column- last sequence and residue is equal to "-"
            if (   ( substr( $seq, $i, 1 ) eq "-" )
                && ( $j == $self->count ) ) {

                # Subtract 1 so it can be used to delete from array index
                push( @{$gaps}, $i );
            }

        }
    }
    return $gaps;
}

# Create alignment position lines

sub _create_aln_positions {
    my ( $self, $size ) = @_;

    my ( $row1, $row10, $row100, $row1000 ) = [];

    #Assumes alignment length is less than 9999
    for ( my $i = 1; $i <= $size; $i++ ) {

        my @num = split( //, sprintf( "%04d", $i ) );

      #Sub '0' for '*', to prevent undef matching later !Must be swapped back!
        push( @{$row1},    ( $num[3] ) ? $num[3] : '*' );
        push( @{$row10},   ( $num[2] ) ? $num[2] : '*' );
        push( @{$row100},  ( $num[1] ) ? $num[1] : '*' );
        push( @{$row1000}, ( $num[0] ) ? $num[0] : '*' );
    }

    return {
        Aln_1    => $row1,
        Aln_10   => $row10,
        Aln_100  => $row100,
        Aln_1000 => $row1000,
    };
}

# Create line to identify binding site positions

sub _create_site_positions {
    my ( $self, $sites, $size ) = @_;
    my $row = [];

    for ( my $i = 0; $i < $size; $i++ ) {
        push( @{$row}, "-" );
    }

    foreach my $site ( @{$sites} ) {
        next, if ( $site - 1 < 0 );
        $row->[ $site - 1 ] = "X";
    }
    return $row;
}

1;
