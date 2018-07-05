package SARfari::Controller::Report;
# $Id: Report.pm 780 2011-12-01 21:15:26Z sarfari $

# SEE LICENSE

use Data::Dumper;
use strict;
use warnings;
use base 'Catalyst::Controller';

sub auto : Private {
    my ( $self, $c ) = @_;
    $c->stash->{subtitle} = "Report";
}

# Display compound report

sub compound : LocalRegex('compound/(\d+)$') {
    my ( $self, $c ) = @_;

    my ($sarregno) = @{ $c->request->snippets };

    # Properties
    $c->stash->{prop_rs} = $c->model('SARfariDB::CompoundDictionary')->search(
        'me.sarregno' => $sarregno,
        {   prefetch => [qw/ property /],
            join     => [qw/ mol /],
            select   => [
                'me.sarregno', { 'chime_string' => 'mol.ctab' }, 'mol.molweight',
                'mol.molformula', 'me.parent_sarregno', 'mol.smiles', 'mol.inchi',
                'mol.inchi_key', 
            ],
            as => [qw/ sarregno chime_string molweight molformula parent_sarregno 
                       smiles inchi inchi_key /]
        }
    )->first;

    # CompoundDictionary
    $c->stash->{comd_rs} = $c->model('SARfariDB::CompoundDictionary')->search(
        'me.sarregno' => $sarregno
    )->first;

    # Check domain has been returned
    if ( !$c->stash->{prop_rs} ) {
        Catalyst::Exception->throw("Compound not identified: $sarregno");
    }

    # External Registration Number
    my $idmap_rs =
        $c->model('SARfariDB::CompoundIdmaps')
        ->search( 'me.sarregno' => $sarregno );

    while ( my $id = $idmap_rs->next ) {
        my $source = uc( $id->source );
        $source =~ s/_VIRTUAL$//;    # Group virtuals
        push( @{ $c->stash->{source}->{$source}->{extreg} }, $id->extreg );
    }

    # Synonyms
    my $synonym_rs =
        $c->model('SARfariDB::CompoundSynonyms')
        ->search( 'me.sarregno' => $sarregno );
    
    my $drugstore = [];
    
    while ( my $syn = $synonym_rs->next ) {
        $c->stash->{synonyms}->{ $syn->syn } = 1;
        
        # Used in following drugstore section
        # Requires all drugstore entries to have a drugstore synonym
        if(uc($syn->syn_source) eq "DRUGSTORE"){
        	push(@{$drugstore},$syn->syn)
        }
    }

    # Drugstore
    if(scalar (@{$drugstore}) > 0){
    $c->stash->{drugstore} = join(', ',@{$drugstore});    	
    $c->stash->{drug2domain} =  [map { {'dom_id' => $_->[0], 'gene_domain_name' => $_->[1]  } }
        $c->model('SARfariDB::DrugstoreToDomains')->search(
            { 'me.sarregno' => $sarregno },
            { select => [qw/ me.dom_id gene_domain.gene_domain_name /],
              join   => [ {'domain' => 'gene_domain'} ],
              order_by => [qw/ gene_domain.gene_domain_name /]}
            )->cursor->all
    ];
    }
    
    # PDB
    my $pxs = $c->model("SARfariDB::X3dLigandToPdb")->pdbligToPx($sarregno);
    
    if(scalar (@{$pxs}) > 0){
        $c->stash->{pdb} = $c->model('SARfariDB::X3dPdbDomain')->getStructureDetails($pxs);
        $c->log->debug($c->stash->{pdb});
    }    
    
    # Candistore
    $c->stash->{candistore} =
        $c->model('SARfariDB::Candistore')->search(
            { 'me.sarregno' => $sarregno },
            { prefetch => [qw/ company /]},
    )->first;
    
    if($c->stash->{candistore}){
    $c->stash->{candi2domain} =  [map { {'dom_id' => $_->[0], 'gene_domain_name' => $_->[1]  } }
        $c->model('SARfariDB::CandistoreToDomains')->search(
            { 'candi.sarregno' => $sarregno },
            { select => [qw/ me.dom_id gene_domain.gene_domain_name /],
              join   => [ {'domain' => 'gene_domain'}, 'candi'],
              order_by => [qw/ gene_domain.gene_domain_name /]}
            )->cursor->all
    ];
    }
    
    #Compound Parent/Salts
    $c->stash->{children} = [
        $c->model('SARfariDB::CompoundDictionary')->search(
            'me.parent_sarregno' => $c->stash->{prop_rs}->parent_sarregno
            )->all
    ];

    # Bioactivities
    $c->stash->{bio_rs} =
        $c->model('SARfariDB::AppCompoundReportBio')->find($sarregno);

    # Documents
    $c->stash->{doc_rs} = [
        $c->model('SARfariDB::CompoundBatches')->search(
            'me.sarregno' => $sarregno,
            { prefetch => [qw/ star_doc /] }
            )->all
    ];

    $c->stash->{sarregno} = $sarregno;

    # View Results
    $c->stash->{body} = "report/compound.tt";
}

# Display protein report

sub protein : LocalRegex('protein/(\d+)$') {
    my ( $self, $c ) = @_;

    my ($dom_id) = @{ $c->request->snippets };

    # Initial Query
    $c->stash->{summary_rs} = $c->model('SARfariDB::ProtDomain')->search(
        {  
            'me.dom_id' => $dom_id 
        },
        {   prefetch => [
                {   'gene_domain' =>
                        [ { 'target' => 'taxon' }, 'classification' ]
                }
            ]
        }
    )->first;

    # Target Dictionary
    my $tid = $c->model('SARfariDB::StarliteToSarfari')->search( 
        {'me.dom_id' => $dom_id },{}
    )->first;

    if( !$tid ){
    }else{
        $c->stash->{summary_tg} = $c->model('SARfariDB::TargetDictionary')->search(
            {'me.tid' => $tid->tid},{}
        )->first;
    }

    # Check domain has been returned
    if ( !$c->stash->{summary_rs} ) {
        Catalyst::Exception->throw("Domain not identified: $dom_id");
    }

    # Synonyms
    my $synonym_rs =
        $c->model('SARfariDB::ProtSynonym')->search( 'me.dom_id' => $dom_id );

    while ( my $syn = $synonym_rs->next ) {
        push( @{ $c->stash->{synonyms} }, $syn->syn );
    }

    # Drugstore
    my $drugstore = [
        $c->model('SARfariDB::DrugstoreToDomains')->search(
            {   'me.dom_id'           => $dom_id,
                'synonyms.syn_source' => 'DRUGSTORE'
            },
            {   join   => [qw/ mol synonyms /],
                select => [
                    'me.sarregno', 'synonyms.syn',
                    { 'chime_string' => 'mol.ctab' }
                ]
            }
            )->cursor->all
    ];

    # Avoid processing drugstore data structure in template
    foreach my $row ( @{$drugstore} ) {
        $c->stash->{drugstore}->{ $row->[0] }->{chime_string} = $row->[2];
        push(
            @{ $c->stash->{drugstore}->{ $row->[0] }->{synonyms} },
            $row->[1]
        );
    }

    # Candistore
    $c->stash->{candistore} = [
        $c->model('SARfariDB::CandistoreToDomains')->search(
            { 'me.dom_id' => $dom_id },
            {   prefetch => [ { 'candi'        => 'mol' } ],
                select   => [ { 'chime_string' => 'mol.ctab' } ],
                as => ['chime_string']    
            }
            )->all
    ];

    my $null = "is null";
    $c->stash->{candistore_ns} = [
        $c->model('SARfariDB::CandistoreToDomains')->search(
            { 'me.dom_id'      => $dom_id,
              'candi.sarregno' => \$null },
            {   prefetch => [ 'candi' ]  }
            )->all
    ];

    # Natural ligands- Protein
    $c->stash->{natlig}->{protein} = [
        $c->model('SARfariDB::NatligLigidToDomains')
            ->search( { 'me.dom_id' => $dom_id },
            { prefetch => [qw/ nl_prot /] } )->all
    ];

    # Natural ligands- Smallmol
    $c->stash->{natlig}->{smallmol} = [
        $c->model('SARfariDB::NatligLigidToDomains')->search(
            { 'me.dom_id' => $dom_id },
            {   join   => [ { nl_smol => [ 'mol', 'comp_dic' ] } ],
                select => [
                    'comp_dic.sarregno', 'mol.molweight',
                    'mol.molformula', { 'chime_string' => 'mol.ctab' },
                    'comp_dic.synonyms'
                ],
                as => [
                    'sarregno', 'molweight', 'formula', 'chime_string',
                    'synonyms'
                ]
            }
            )->all
    ];

    # Get GDID
    my $ged_id = $c->stash->{summary_rs}->ged_id;

    # Get Domain Variant Details
    $c->stash->{variants} = [
        $c->model('SARfariDB::ProtDomain')->search(
            { 'me.ged_id' => $ged_id },
            {   prefetch => [qw/ prot_comp prot_bio gene_domain /],
                order_by => [qw/ me.dom_id /]
            }
            )->all
    ];

    # Accessions
    my $accession_rs =
        $c->model('SARfariDB::ProtAccession')
        ->search( { 'domain.ged_id' => $ged_id },
        { join => [qw/ domain /] } );

    while ( my $acc = $accession_rs->next ) {
        push(
            @{ $c->stash->{accessions}->{ $acc->dom_id } },
            $acc->accession
        );
    }

    $c->stash->{dom_id} = $dom_id;

    # View results
    $c->stash->{body} = "report/protein.tt";
}

# Download target profile details for a compound

sub profile : LocalRegex('profile/(\d+)$') {
    my ( $self, $c ) = @_;

    my ($sarregno) = @{ $c->request->snippets };

    my $pro_rs = $c->model('SARfariDB::ActivitiesToDomains')->search(
        {   'me.sarregno'      => $sarregno,
            'me.assay_type'    => 'B',
            'me.activity_type' => [ 'IC50', 'Ki', 'Kd' ]
        },
        {   select => [
                'me.short_name',    'me.activity_type',
                'me.relation',      'me.standard_value',
                'me.standard_unit', 'me.activity_comment',
                'me.source'
            ]
        }
    );

    my $download = [
        "Target\tActivity Type\tRelation\tStandard Value\tStandard Unit\tActivity Comment\tSource"
    ];

    my $cursor = $pro_rs->cursor;

    while ( my @r = $cursor->next ) {
        push( @{$download}, join( "\t", @r ) );
    }

    my $filename = "$sarregno\_target_profile.txt";

    $c->res->header( 'Content-Disposition',
        qq[attachment; filename="$filename"] );
    $c->res->content_type('text/plain');
    $c->res->body( join( "\n", @{$download} ) );
}

1;
