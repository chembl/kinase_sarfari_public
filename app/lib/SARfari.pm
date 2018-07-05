package SARfari;
# $Id: SARfari.pm 773 2011-10-17 15:45:38Z mdavies $

# SEE LICENSE

use strict;
use warnings;

use Catalyst::Runtime '5.70';

use Catalyst qw/
    ConfigLoader
    
    Static::Simple

   Session
   Session::Store::Memcached
   Session::State::Cookie

    Scheduler
    
    Browser
    /;

our $VERSION = '0.01';

print "
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!                                                         !
! Remember to include sarfari_local.yml for live releases !
!                                                         !
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
";

if($ENV{'DATACENTRE'}){	
	__PACKAGE__->config( 'Plugin::ConfigLoader' => {
        config_local_suffix => $ENV{'DATACENTRE'}
    });
}

# Start the application
__PACKAGE__->setup;
 
# Schedule configuration
__PACKAGE__->schedule(
    at         => '* 0 * * *',
    event      => '/admin/clear_expired_session_data',
);

1;
