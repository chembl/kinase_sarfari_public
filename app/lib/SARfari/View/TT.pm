package SARfari::View::TT;
# $Id: TT.pm 180 2009-08-27 10:13:14Z mdavies $

# SEE LICENSE

use strict;
use base 'Catalyst::View::TT';
use Template::Stash::XS;
use URI::Escape;

__PACKAGE__->config(
    'INCLUDE_PATH'       => SARfari->path_to('root/templates/'),
    'COMPILE_DIR'        => "/tmp/template_cache",
    'COMPILE_EXT'        => '.ttc',
    'CACHE_SIZE'         => 64,
    'TEMPLATE_EXTENSION' => '.tt',
    'FILTERS'            => {
        'sarfari_round' => sub { sarfari_round( $_[0] ) },
        'uri_escape'    => sub { URI::Escape::uri_escape(@_) },
    }
);

# Filter used to tidy up bioactivity results

sub sarfari_round{
    my  $value = shift;
    
    if(int $value == $value){
        return $value;
    }
    
    return  sprintf("%.2f", $value);
}

1;
