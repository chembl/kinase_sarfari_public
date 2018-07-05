package SARfari::Schema::ResultSet::RsDual;
# $Id: RsDual.pm 553 2010-02-04 23:38:23Z mdavies $

# SEE LICENSE

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use Carp;

# This class is primarily used to call custom oracle functions #

# Convert incoming molfile to a chime string

sub molToChime {
    my ( $self, $molfile ) = @_;

    my $query;

    eval {
        $query = $self->search(
            undef,
            {   select => {
                    chime_string => [ $molfile ]
                },
                as => [qw/ chime_string /],
            },
        )->first;
    };

    # Pass exception up the chain
    if ($@) {
        croak($@);
    }

    return $query->get_column('chime_string');
}

sub chimeToInchiKey {
    my ( $self, $chime ) = @_;

    my $query;

    eval {
        $query = $self->search(
            undef,
            {   select => {
                    inchikey => [{mol => $chime}]
                },
                as => [qw/ inchikey /],
            },
        )->first;
    };

    # Pass exception up the chain
    if ($@) {
        croak($@);
    }

    return ($query) ? $query->get_column('inchikey') : undef;
}

sub smilesToChime {
    my ( $self, $smiles ) = @_;

    my $query;

    eval {
        $query = $self->search(
            undef,
            {   select => {
                    chime_string => [{mol => $smiles}]
                },
                as => [qw/ chime_string /],
            },
        )->first;
    };

    # Pass exception up the chain
    if ($@) {
        croak($@);
    }

    return $query->get_column('chime_string');
}

sub smilesToMolfile {
    my ( $self, $smiles ) = @_;

    my $query;

    eval {
        $query = $self->search(
            undef,
            {   select => {
                    molfile => [{mol => $smiles}]
                },
                as => [qw/ molfile /],
            },
        )->first;
    };

    # Pass exception up the chain
    if ($@) {
        croak($@);
    }

    return $query->get_column('molfile');
}


# Run compound search (substructure, flexmatch, similarity)

sub cmpdSearch {
    my ( $self, $sessionid, $username, $chime_string, $chime_md5, $query_type,
        $db, $cut_off )
        = @_;

    my $query;

    eval {
        $query = $self->search(
            undef,
            {   select => {
                    cmpd_search => [
                        $sessionid, $username,   $chime_string,
                        $chime_md5, $query_type, $db,
                        $cut_off
                    ]
                },
                as => [qw/ job_id /],
            },
        )->first;
    };

    # Pass exception up the chain
    if ($@) {
        croak($@);
    }

    return $query->get_column('job_id');
}

# Run bioactivity search

sub bioSearch {
    my ( $self, $jobid, $search_type, $where_clause ) = @_;

    my $query;

    # Check for optional final parameter
    my $bio_search_params = [ $jobid, $search_type ];

    if ( defined $where_clause ) {
        push( @{$bio_search_params}, $where_clause );
    }

    eval {
        $query =
            $self->search( undef,
            { select => { bio_search => $bio_search_params }, },
            )->first;
    };

    # Pass exception up the chain
    if ($@) {
        croak($@);
    }
}

# Move inserts to db function

sub bulkIdInsert {
    my ( $self, $jobid, $batch, $load_data_type ) = @_;

    my $query;

    eval {
        $query = $self->search(
            undef,
            {   select =>
                    { bulk_id_insert => [ $jobid, $batch, $load_data_type ] },
            },
        )->first;
    };

    # Pass exception up the chain
    if ($@) {
        croak($@);
    }
}

# Move inserts to db function

sub cmpdSearchTxt {
    my ( $self, $jobid, $sessionid, $username, $query_type, $query_string,
        $db )
        = @_;    

    my $query;

    eval {
        $query = $self->search(
            undef,
            {   select => {
                    cmpd_search_txt => [
                        $jobid,      $sessionid,    $username,
                        $query_type, $query_string, $db
                    ]
                },
            },
        )->first;
    };

    # Pass exception up the chain
    if ($@) {
        croak($@);
    }
}

# Return jobid used in compound and bioactivity searches

sub getJobid {
    my ($self) = @_;

    my $query;

    eval {
        $query = $self->search(
            undef,
            {   select => [qq/ app_search_jobid_sq.NEXTVAL /],
                as     => [qw/ job_id /],
            },
        )->first;
    };

    # Pass exception up the chain
    if ($@) {
        croak($@);
    }

    return $query->get_column('job_id');
}

# Remove expired session data

sub sessionClean {
    my ($self) = @_;

    eval {
        $self->search( undef,
            { select => [ 'bio_session_clean', 'cmpd_session_clean' ] },
        )->first;
    };

    # Pass exception up the chain
    if ($@) {
        croak($@);
    }
}

# Move cmpd regnos to bio search

sub cmpdToBio {
    my ( $self, $jobid ) = @_;

    my $query;

    eval {
        $query = $self->search(
            undef,
            {   select =>
                    { cmpd_to_bio => [ $jobid ] },
            },
        )->first;
    };

    # Pass exception up the chain
    if ($@) {
        croak($@);
    }
}


# Delete old bio data

sub removeBioData {
    my ( $self, $jobid ) = @_;

    my $query;

    eval {
        $query = $self->search(
            undef,
            {   select =>
                    { remove_bio_data => [ $jobid ] },
            },
        )->first;
    };

    # Pass exception up the chain
    if ($@) {
        croak($@);
    }
}
1;
