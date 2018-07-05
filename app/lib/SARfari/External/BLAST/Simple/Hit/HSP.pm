package SARfari::External::BLAST::Simple::Hit::HSP;
use strict;
use Carp;
use Readonly;

sub new{
    my $class = shift;
    my $self = bless {}, $class;
    my $hsp_data = $self->_parse_hsp(shift);
    
    $self->{score}        = $hsp_data->[0];
    $self->{bit_score}    = $hsp_data->[1];
    $self->{evalue}       = $hsp_data->[2];
    $self->{identity}     = $hsp_data->[3];
    $self->{positives}    = $hsp_data->[4];
    $self->{gaps}         = $hsp_data->[5];
    $self->{query_from}   = $hsp_data->[6];
    $self->{query_to}     = $hsp_data->[7];
    $self->{subject_from} = $hsp_data->[8];
    $self->{subject_to}   = $hsp_data->[9];
    
    return $self;
}


sub get_score {
    my ($self) = @_;
    return $self->{score};
}


sub get_bit_score {
    my ($self) = @_;
    return $self->{bit_score};
}


sub get_evalue {
    my ($self) = @_;
    return $self->{evalue};
}


sub get_identity {
    my ($self) = @_;
    return $self->{identity};
}

sub get_positives {
    my ($self) = @_;
    return $self->{positives};
}


sub get_gaps {
    my ($self) = @_;
    return $self->{gaps};
}


sub get_query_from {
    my ($self) = @_;
    return $self->{query_from};
}


sub get_query_to {
    my ($self) = @_;
    return $self->{query_to};
}


sub get_subject_from {
    my ($self) = @_;
    return $self->{subject_from};
}


sub get_subject_to {
    my ($self) = @_;
    return $self->{subject_to};
}


sub _parse_hsp{
    my ($self, $hsp) = @_;
    
    Readonly my $HSP_LINE => qr { 
                                             (\d+)   #Score
        \s+bits\s+\(
                                             (\d+)   #Bit sore
        \),\s+Expect\s+=\s+
                                             (.*?)   #E-value
        \s+Identities\s+=\s+\d+/\d+\s+\(
                                             (\d+)   #Identity
        \%\),\s+Positives\s+=\s+\d+/\d+\s+\(
                                             (\d+)   #Positives
        \%\)(,\s+Gaps\s+=\s+\d+/\d+\s+\(
                                             (\d+)   #Gaps
        \%\))?                                       #Gaps section optional
    }xs;
    
    my ($score, $bit_score, $evalue, $identity, $positives, $gap_section, $gaps_id) = $hsp =~ $HSP_LINE;
    my $gaps = $gaps_id || 0; #When no gaps present this section does not appear in output
    $evalue =~ s/^e/1e/i;
    
    my ($query_from,$query_to)     = _hsp_from_to("Query", $hsp);
    my ($subject_from,$subject_to) = _hsp_from_to("Sbjct", $hsp);
    
    return [$score, $bit_score, $evalue, $identity, $positives, 
            $gaps,$query_from,$query_to, $subject_from,$subject_to];
}


sub _hsp_from_to{
    my ($type, $hsp) = @_;
    	
    my @lines = $hsp =~ /$type:\s+\d+\s+[^\s]+\s+\d+/g;
    
    my $line_count = scalar(@lines);
    
    my $first_line = shift(@lines);
    $first_line =~ m/^$type:\s+(\d+)/;
    my $from =  $1;
    
    #There may only be 1 blast alignment row
    my $last_line = ($line_count == 1) 
                    ? $first_line
                    : pop(@lines);
    
    $last_line =~ m/(\d+)$/;
    my $to =  $1;
    
    return($from,$to);
}

1;
