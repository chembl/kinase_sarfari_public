package SARfari::Schema::ResultSet::RsSiteDefinitions;
# $Id: RsSiteDefinitions.pm 155 2009-08-25 11:02:39Z mdavies $

# SEE LICENSE

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use Carp;
use Data::Dumper;

sub getSiteAlign {
    
    my ($self, $params) = @_;    
     
    my $filter = {
      'me.site_id'             => $params->{'site'},
      'aln_positions.dom_id'   => $params->{'query'},    
      'aln_positions_2.dom_id' => $params->{'target'},
    };

    my $joins = [ 
      {'aln_positions' => {'domain' => 'gene_domain'} },
      {'aln_positions' => {'domain' => 'gene_domain'} },
    ];
                                                            
    my $select_cols = [
      'me.aln_pos',
      'me.weighting',
      'aln_positions.residue',
      'gene_domain.gene_domain_name',
      'aln_positions_2.residue',
      'gene_domain_2.gene_domain_name',
    ];
        
    my $details;
         
    eval {
        $details = [
            $self->search(
                $filter,
                {   select => $select_cols,
                    join   => $joins,
                }
                )->cursor->all
        ];
    };                                     
    # Pass exception up the chain
    if ($@) {
        croak($@);
    }

    my $mapped_details =
        [ map { map_columns( $_, $select_cols ) } @{$details} ];

    return $mapped_details;
}

# Quick sub to create href, mapping column names to data

sub map_columns {
    my $data = shift;
    my $cols = shift;

    my $mapped = {};

    for ( my $i = 0; $i < scalar( @{$data} ); $i++ ) {
        
        my $tmp = $cols->[$i];
            	
    	# May join to same table twice
    	if($tmp =~ /\_2\./){
    	   $tmp .= "2";
    	}

        $tmp =~ s/^\w+\.//;    # Remove table alias
        $mapped->{$tmp} = $data->[$i];
    }

    return $mapped;
}

1;