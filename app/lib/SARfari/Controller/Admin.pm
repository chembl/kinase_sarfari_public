package SARfari::Controller::Admin;
# $Id: Admin.pm 142 2009-08-25 10:28:03Z mdavies $

# SEE LICENSE

use strict;
use warnings;
use base 'Catalyst::Controller';

sub auto : Private {
    my ( $self, $c ) = @_;
}

sub index : Private {
    my ( $self, $c ) = @_;

    $c->stash->{body} = "home.tt";
}

sub clear_expired_session_data : Private {
    my ( $self, $c ) = @_;
    
    $c->model('SARfariDB::Dual')->sessionClean();
}

1;
