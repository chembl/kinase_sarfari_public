package SARfari::External::Sequence::Simple;
# $Id: Simple.pm 145 2009-08-25 10:31:05Z mdavies $

# SEE LICENSE

use strict;
use Carp;
use Data::Dumper;
use Digest::MD5 qw(md5_hex);

sub new{
    my $class   = shift;
    
    my $self = bless {}, $class;
    
    $self->{id}  = shift;
    $self->{seq} = shift;
    
    return $self;
}

sub get_id {
    my $self   = shift;
    return $self->{id};
}

sub get_seq {
    my $self   = shift;
    return $self->{seq};
}

sub get_seq_nogaps {
    my $self   = shift;
    my $tmp = $self->{seq};
    $tmp =~ s/\-//g;
    $tmp =~ s/\s//g;
    $tmp =~ s/\///g; #removing chain breaks
    return $tmp;
}

sub get_fasta {
    my $self = shift;
    my $header = $self->get_id;
    $header = ($header =~ /^>/)
               ? $header
               : ">$header";
    
    return $header."\n".$self->get_seq_nogaps."\n";
}

sub get_md5 {
    my $self   = shift;
    my $tmp = $self->{seq};
    $tmp =~ s/\-//g;
    $tmp =~ s/\s//g;
    $tmp =~ s/\r//g;
    my $digest = md5_hex($tmp);
    return $digest;
}

1;
