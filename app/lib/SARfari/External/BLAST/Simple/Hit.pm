package SARfari::External::BLAST::Simple::Hit;
use strict;
use Carp;
use SARfari::External::BLAST::Simple::Hit::HSP;

sub new{
    my $class = shift;
    my $self = bless {}, $class;
    
    $self->{name}       = "";
    $self->{length}     = 0;
    $self->{hsps}       = [];
    $self->{iterator}   = 0;
    $self->{data_count} = 0;
    $self->_parse_data(shift);
    
    return $self;
}


sub get_name {
    my ($self) = @_;
    return $self->{name};
}


sub get_length {
    my ($self) = @_;
    return $self->{length};
}


sub first_hsp{
    my $self = shift;
    return $self->{hsps}->[0];
}


sub next{
    my $self = shift;
    
    if ($self->{iterator} == $self->{data_count}){
        $self->iterator_reset();
        return undef;
    }
    
    my $tmp = $self->{iterator};
    $self->{iterator}++;
    
    return $self->{hsps}->[$tmp];
}


sub iterator_reset{
    my $self = shift;
    $self->{iterator} = 0;
}


sub _parse_data {
    my ($self, $blast_aln) = @_; 
    
    $blast_aln =~ s/\n//g;
    $blast_aln =~ m/^(.*?)\s+Length\s+=\s+(\d+)\s+/;
    
    $self->{name}   = $1;
    $self->{length} = $2;
    
    #print $blast_aln."\n\n";
    my @hsps = split(/Score\s+=/,$blast_aln);
    shift @hsps;
    
    foreach my $raw_hsp (@hsps){
        $self->{data_count}++;
        push(@{$self->{hsps}}, SARfari::External::BLAST::Simple::Hit::HSP->new($raw_hsp));
    }
}

1;
