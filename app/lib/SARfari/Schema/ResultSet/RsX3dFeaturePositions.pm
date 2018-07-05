package SARfari::Schema::ResultSet::RsX3dFeaturePositions;
# $Id: RsX3dFeaturePositions.pm 602 2010-04-12 09:50:59Z sarfari $

# SEE LICENSE

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use Carp;
use Data::Dumper;

#

sub get_features : ResultSet {
    my ($self, $px) = @_;
        
    my $test = $self->search(
        'aln.px' => $px,
        {select   => ['feature.feature_name', 
                      'aln.residue', 
                      'aln.pdb_resnum', 
                      'aln.aln_pos'
                     ],
         prefetch => [ 'feature', 'aln']}
    );
    
    my $cursor = $test->cursor;
    
    my $feature_details = {};
    
    
    while(my @r = $cursor->next){        
            push(@{$feature_details->{$r[0]}}, 
            {   residue => $r[1],
                resnum  => $r[2],
                alnpos  => $r[3]
            });
    }
    
    return $feature_details;
} 


# Hash using faeture as key

sub get_features_pos : ResultSet {
    my ($self,) = @_;
        
    my $featpos_rs = $self->search(
        undef,
        {prefetch => [ 'feature' ]}
    );
    
    my $feature_pos = {};
    
    while(my $row = $featpos_rs->next){
        push(@{$feature_pos->{$row->feature->feature_name}}, $row->aln_position);        
    }
    return $feature_pos;
} 

# Hash using alignment pos as key

sub get_pos_features : ResultSet {
    my ($self,) = @_;
        
    my $featpos_rs = $self->search(
        undef,
        {prefetch => [ 'feature' ]}
    );
    
    my $pos_feature = {};
    
    while(my $row = $featpos_rs->next){
        push(@{$pos_feature->{$row->aln_position}}, $row->feature->feature_name);        
    }
    return $pos_feature;
} 

1;
