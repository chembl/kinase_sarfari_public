package SARfari::Model::SARfariDB;
# $Id: SARfariDB.pm 239 2009-10-07 15:16:20Z mdavies $

# SEE LICENSE

use strict;
use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => 'SARfari::Schema::SARfariSchema',
    connect_info => [
        "DBI:"
            . SARfari->config->{database}->{driver} . ":"
            . SARfari->config->{database}->{name},
        SARfari->config->{database}->{username},
        SARfari->config->{database}->{password},
        { AutoCommit => 1, LongReadLen => 10_000_000, PrintError => 0 },
        {   on_connect_do => [
                'ALTER SESSION SET NLS_DATE_FORMAT = \'YYYY/MM/DD HH24:MI:SS\''
            ]
        }
    ]
);

1;
