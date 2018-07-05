package SARfari::External::BLAST::Simple;
# $Id: Simple.pm 330 2009-10-30 17:07:48Z mdavies $

# SEE LICENSE

use strict;
use Carp;
use English;
use Data::Dumper;
use Readonly;
use SARfari::External::BLAST::Simple::Hit;

sub new{ 
    my $class = shift;
    my $self = bless {}, $class;
    
    $self->{filename} = shift;
        
    if(!-e $self->{filename}){
        croak("BLAST file does not exist: $self->{file}");
    }
    
    $self->{iterator}     = 0;
    $self->{data_count}   = 0;
    $self->{query_name}   = "";	
    $self->{query_length} = 0;
    $self->_parse_blast_file($self->{filename});
    
    return $self;
}


sub get_query_name {
    my $self = shift;
    return $self->{query_name}
}


sub get_query_length {
    my $self = shift;
    return $self->{query_length}
}


sub next{
    my $self = shift;
    
    if ($self->{iterator} == $self->{data_count}){
        $self->iterator_reset();
        return undef;
    }
    
    my $tmp = $self->{iterator};
    $self->{iterator}++;
    
    return $self->{hits}->[$tmp];
}


sub iterator_reset{
    my $self = shift;
    $self->{iterator} = 0;
}


sub _parse_blast_file{
    my ($self, $filename) = @_;
    
    open my $fh, '<', $filename
        or croak "Can't open '$filename': $OS_ERROR";
    
    #Dealing with standard blast output
    $/ = "\n>";
    
    #Skip first
    my $search_details = <$fh>;
        
    Readonly my $QUERY_DETAILS => qr {
    	Query=\s+    (.*?)   # Query name
    	\s+\(        (\d+)   # Query length
    	\s+letters\)
    }xms;
    
    $search_details =~ $QUERY_DETAILS;
    $self->{query_name}   = $1;	
    $self->{query_length} = $2;
    
    while(my $hit = <$fh>){
        $self->{data_count}++;
        push(@{$self->{hits}}, SARfari::External::BLAST::Simple::Hit->new($hit));
    }
    
    close $fh
        or croak "Can't close '$filename' after reading: $OS_ERROR";
}

1;
