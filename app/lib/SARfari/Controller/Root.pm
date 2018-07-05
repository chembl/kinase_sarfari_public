package SARfari::Controller::Root;
# $Id: Root.pm 791 2012-01-18 13:39:23Z mdavies $

# SEE LICENSE

use strict;
use warnings;
use base 'Catalyst::Controller';
use Data::Dumper;
use List::MoreUtils qw( uniq );

__PACKAGE__->config->{namespace} = '';

sub auto : Private {
    my ( $self, $c ) = @_;
    
    $c->stash->{template}     = "wrapper.tt";
    $c->stash->{left_menu_id} = 4;
    
    if($c->config->{enforce_https}){
        my $uri = $c->req->base()->scheme("https");
        $c->stash->{secure} = 1;
    }
    
    #eval{
     	$c->model('SARfariDB')->storage->ensure_connected;
	#};
	
	#if($@){
	#	$c->response->body("The site is off the air temporarily for maintenance - please check back shortly.");
	#}
	
    # Populate session data
    if ( !( $c->session->{username} ) ) {
        $c->session->{username} = lc( $ENV{LOGNAME} || 'guest' );
    }

    $c->stash->{subtitle} = "Kinase SARfari";

    return 1;
}

sub default : Private {
    my ( $self, $c ) = @_;

    $c->stash->{app_counts} =
        $c->model('SARfariDB::AppCounts')->search(
   		undef,
        { order_by => "me.display_order" }
    );  
        
    $c->stash->{body} = "home.tt";
}

# Structure home

sub structure : Local {
    my ( $self, $c ) = @_;

    $c->stash->{subtitle} = "3D Structure";
    $c->stash->{body}     = "structure/structure_home.tt";
}

# User guide

sub userguide : Local {
    my ( $self, $c ) = @_;

    $c->stash->{subtitle} = "User Guide";
    $c->stash->{body}     = "userguide/userguide_home.tt";
}

# Downloads page

sub downloads : Local {
    my ( $self, $c ) = @_;

    $c->stash->{subtitle} = "Download";
    $c->stash->{body}     = "download/download.tt";
}

# Method runs system search

sub system_search : Local {
    my ( $self, $c ) = @_;
    
    # We are doing a get so clean url
    $c->flash->{query} = $c->req->params->{'qString'};
    $c->res->redirect( $c->uri_for("/system_results") );    
    $c->detach();
}


sub status : Path('/utils/status') {
    my ( $self, $c ) = @_;
    $c->response->body('OK');
}



# Methods displays system search results

sub system_results : Local {
    my ( $self, $c ) = @_;

    if($c->stash->{query} && length($c->stash->{query}) > 2 ){

        # Get domains
        $c->stash->{dom_ids} = [uniq @{$c->model("SARfariDB::ProtDomain")->allToDomid($c->stash->{query})}];
    
        my $quoted_string = $c->model('SARfariDB::Dual')->result_source->schema->storage->dbh->quote(uc($c->stash->{query}));    
        $quoted_string =~ s/^\'/\'\%/;
        $quoted_string =~ s/\'$/\%\'/;
        
        # Get domains
        $c->stash->{sarregnos} = 
            [
              map { $_->[0] } $c->model("SARfariDB::AppSearchFieldComp")->search(
                  undef,
                  {select => [ {'distinct' => 'me.sarregno'} ] }
                  )->search_literal(
                  " me.field like $quoted_string "
                  )->cursor->all
            ];
    }


    $c->stash->{subtitle} = "SARfari System Search";
    $c->stash->{body}     = "system_search.tt";
}

sub end : ActionClass('RenderView') {
    my ( $self, $c ) = @_;
	
	# Stop cursor build up
	$c->model('SARfariDB')->storage->disconnect;
	
    # Custom error
    if ( @{ $c->error } ) {
        $c->flash->{error} = $c->error;    # returns arrayref
        $c->error(0);
        $c->res->redirect( $c->uri_for('/error') );
    }
}

1;
