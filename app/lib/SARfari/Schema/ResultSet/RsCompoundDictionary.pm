package SARfari::Schema::ResultSet::RsCompoundDictionary;
# $Id: RsCompoundDictionary.pm 602 2010-04-12 09:50:59Z sarfari $

# SEE LICENSE

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use Carp;
use Data::Dumper;

# Convert synonym to regno

sub synToRegno {

    my ( $self, $query ) = @_;

    my $regnos;

    my $quoted_string = $self->result_source->schema->storage->dbh->quote(uc($query));    
    $quoted_string =~ s/^\'/\'\%/;
    $quoted_string =~ s/\'$/\%\'/;

    eval {

        $regnos = [
            map { $_->[0] } $self->search(
                undef,
                {   select => [qw / me.sarregno /],
                    join   => [qw / synonyms /]
                }
                )->search_literal(
                " upper(synonyms.syn) like $quoted_string "
                )->cursor->all
        ];
    };

    # Pass exception up the chain
    if ($@) {
        croak($@);
    }

    return $regnos;
}

# Convert external registration number to regno

sub extToRegno {

    my ( $self, $query ) = @_;

    my $regnos;

    my $quoted_string = $self->result_source->schema->storage->dbh->quote(uc($query));    
    $quoted_string =~ s/^\'/\'\%/;
    $quoted_string =~ s/\'$/\%\'/;
    
    eval {

        $regnos = [
            map { $_->[0] } $self->search(
                undef,
                {   select => [qw / me.sarregno /],
                    join   => [qw / idmaps /]
                }
                )->search_literal(
                " upper(idmaps.extreg) like $quoted_string "
                )->cursor->all
        ];
    };

    # Pass exception up the chain
    if ($@) {
        croak($@);
    }

    return $regnos;
}

# Convert protein domain id to regno

sub domidToRegno {

    my ( $self, $query ) = @_;

    my $regnos;

    eval {

        $regnos = [
            map { $_->[0] } $self->search(
                'act2dom.dom_id' => $query,
                {   select => [qw / me.sarregno /],
                    join   => [qw / act2dom /]
                }
                )->cursor->all
        ];
    };

    # Pass exception up the chain
    if ($@) {
        croak($@);
    }

    return $regnos;
}

# Convert protein domain id to regno, with additional bioactivity filter
# Gives high affinity compounds

sub domidIC50ToRegno {

    my ( $self, $query ) = @_;

    my $regnos;

    eval {

        $regnos = [
            map { $_->[0] } $self->search(
                {   'act2dom.dom_id'        => $query,
                    'act2dom.assay_type'    => 'B',
                    'act2dom.relation' => [ '<', '<=', '=', '<<', '~', 'ca' ],
                    'act2dom.standard_value' => { '<=' => 50 }
                },
                {    
                    select => [qw / me.sarregno /],
                    join   => [qw / act2dom /]
                }
                )->search_literal(
                " upper(act2dom.activity_type) like \'IC50\' "                 
                )->cursor->all
        ];
    };

    # Pass exception up the chain
    if ($@) {
        croak($@);
    }

    return $regnos;
}


# Convert protein domain id to regno, with additional bioactivity filter
# Gives high affinity compounds

sub domidKiToRegno {

    my ( $self, $query ) = @_;

    my $regnos;

    eval {

        $regnos = [
            map { $_->[0] } $self->search(
                {   'act2dom.dom_id'        => $query,
                    'act2dom.assay_type'    => 'B',
                    'act2dom.relation' => [ '<', '<=', '=', '<<', '~', 'ca' ],
                    'act2dom.standard_value' => { '<=' => 50 }
                },
                {    
                    select => [qw / me.sarregno /],
                    join   => [qw / act2dom /]
                }
                )->search_literal(
                " upper(act2dom.activity_type) like \'KI\' "                
                )->cursor->all
        ];
    };

    # Pass exception up the chain
    if ($@) {
        croak($@);
    }

    return $regnos;
}

1;
