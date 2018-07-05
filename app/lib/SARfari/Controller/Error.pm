package SARfari::Controller::Error;
# $Id: Error.pm 142 2009-08-25 10:28:03Z mdavies $

# SEE LICENSE

use strict;
use warnings;
use base 'Catalyst::Controller';



sub auto : Private {
    my ( $self, $c ) = @_;
    $c->stash->{subtitle} = "Error Page";
}

sub index : Private {
    my ( $self, $c, $msg, $simple) = @_;
    
    # Optional
    $c->stash->{msg} = $msg;
    
    $c->stash->{body} = "error/error.tt";
    
    $c->stash->{simple} = ($simple) ? 1 : undef;
}

1;
