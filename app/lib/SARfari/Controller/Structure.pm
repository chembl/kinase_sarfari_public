package SARfari::Controller::Structure;
# $Id: Structure.pm 527 2010-01-22 17:20:33Z mdavies $

# SEE LICENSE

use strict;
use warnings;
use base 'SARfari::BaseController::Search';
use Data::Dumper;

use PerlIO::gzip;
use Archive::Tar;
use Readonly;
use Archive::Zip qw( :ERROR_CODES :CONSTANTS );
use IO::String;

sub auto : Private {
    my ( $self, $c ) = @_;

    $c->stash->{subtitle} = "Structure";
}

sub index : Private {
    my ( $self, $c ) = @_;

    $c->stash->{body} = "structure/structure_home.tt";
}

#

sub processData : Private {
    my ( $self, $c ) = @_;

    my $params = { taxid => $c->req->params->{'taxid'} || undef };

    # Get protein target data
    if ( $c->stash->{data}->{target} ) {
        foreach my $batch ( @{ $c->stash->{data}->{target} } ) {
            push(
                @{ $c->stash->{target_details} },
                grep {$_} @{
                    $c->model('SARfariDB::DomidToSunidpx')
                        ->getStructureDetails( $batch, $params )
                    }
            );
        }
    }
     
    # Get all pdb ligands - not that many so not very expensive
    $c->stash->{pdb_ligands} = $c->model('SARfariDB::X3dLigandToPdb')->getPdbLigands();
    
    # View Results
    $c->stash->{body} = "structure/structure_search_results.tt";
}

sub structureSearch : Private {
    my ( $self, $c ) = @_;

    # Data type is target for structure info
    my $user_data = [ split( '\s+', $c->forward( 'pullData', ['target'] ) ) ];


    my $valid_user_data =
        $c->forward( 'validateData',
        [ $user_data, $c->req->params->{'targetType'} ] );

    $c->stash->{data}->{target} =
        $c->forward( 'createBatches', [$valid_user_data] );

    # Get protein target data
    if ( $c->stash->{data}->{target} ) {
        foreach my $batch ( @{ $c->stash->{data}->{target} } ) {
            push(
                @{ $c->stash->{target_details} },
                grep {$_} @{
                    $c->model('SARfariDB::X3dPdbDomain')
                        ->getStructureDetails($batch)
                    }
            );
        }
    }

    # Get all pdb ligands - not that many so not very expensive
    $c->stash->{pdb_ligands} = $c->model('SARfariDB::X3dLigandToPdb')->getPdbLigands();
    
    # View Results
    $c->stash->{body} = "structure/structure_search_results.tt";
}

# Overides Search.pm's parseData

sub validateData : Private {
    my ( $self, $c, $data_aref, $datatype ) = @_;

    my $DRY_IDS = {};

    foreach my $d ( @{$data_aref} ) {

        # Just add px's
        if ( lc($datatype) eq 'px' ) {

            # Has to be a number
            next, if ( $d !~ /^\d+$/ );
            $DRY_IDS->{$d} = 1;
        }

        # Convert pdbs to pxs
        if ( lc($datatype) eq 'pdb' ) {

            # Has to be 4 chars in length
            next, if ( $d !~ /^....$/ );

            foreach my $converted_id (
                @{ $c->model("SARfariDB::X3dPdbDomain")->pdbToPx($d) } ) {
                $DRY_IDS->{$converted_id} = 1;
            }
        }

        # Convert pdbs to pxs
        if ( lc($datatype) eq 'pdblig' ) {

            # Has to be 4 chars in length
            next, if ( $d !~ /^\d+$/ );

            foreach my $converted_id (
                @{ $c->model("SARfariDB::X3dLigandToPdb")->pdbligToPx($d) } ) {
                $DRY_IDS->{$converted_id} = 1;
            }
        }
    }

    my $ret_aref = [ keys %{$DRY_IDS} ];

    return $ret_aref;
}


# This method takes a list of user selected pxs (refernce and mobile)
# and either redirects user to application 3D viewer or download

sub pdb_fit : Local {
    my ( $self, $c ) = @_;
     
    # user_select param contains both 2 pieces of information
    ( $c->req->params->{'fit_type'}, $c->req->params->{'submit'} ) = 
        split( /\-/, $c->req->params->{'user_select'} );

    # Fit method
    $c->stash->{fit_type} =
        ( $c->req->params->{'fit_type'} )
        ? $c->req->params->{'fit_type'}
        : 'vanilla';

    # The reference domain id:
    # px may come from px-to-seq search, hence conditional
    $c->stash->{fixed_px} =
        ( $c->stash->{'px2seq'} )
        ? $c->stash->{'px2seq'}
        : $c->req->params->{'pdb_ref'};

    # View or download
    $c->stash->{option} = $c->req->params->{'submit'} || "View";

    # Detach from current process if errors occurred when parsing compound 
    # details
    if ( !$c->stash->{fixed_px} ) {
        $c->detach( '/error/index',
            [ "Please select fixed 3D structure", 1 ] );
    }

    # It is not required that a user supplies a mobile structure, however may 
    # sure dealing with arrayref
    if ( $c->req->params->{'pdb_mob'} ) {
        $c->stash->{mobile_px} =
            ( scalar( $c->req->params->{'pdb_mob'} ) =~ /^ARRAY/ )
            ? $c->req->params->{'pdb_mob'}
            : [ $c->req->params->{'pdb_mob'} ];
    }

    # Limit number of mobile structures + 1 ref structure in structure viewer
    my $MAX_MOB = 12;

    if (   $c->stash->{option} eq 'View'
        && $c->stash->{mobile_px}
        && scalar( @{ $c->stash->{mobile_px} } ) + 1 > $MAX_MOB ) {
        $c->detach(
            '/error/index',
            [   "You may view a maximum of $MAX_MOB structures in 3D viewer",
                1
            ]
            ),
            ;
    }

    # Capture all user pxs in single array ref- this is used to carry out 
    # single database query
    my $all_user_pxs_store = [ $c->stash->{fixed_px} ];

    # Get fixed pdb details
    $c->stash->{pdb_details}->{ $c->stash->{fixed_px} } = [
        $c->model('SARfariDB::X3dPdbDomain')->search(
            'me.sunid_px' => $c->stash->{fixed_px},
            { prefetch => ['pdb'] }
            )->first
    ];

    # Get fixed domain aln features
    $c->stash->{all_features} =
        [ $c->model('SARfariDB::X3dFeature')->search()->all ];
    $c->stash->{features_pos} =
        $c->model('SARfariDB::X3dFeaturePositions')->get_features_pos();

    # Get fixed domain aln features
    $c->stash->{pdb_features}->{ $c->stash->{fixed_px} } =
        $c->model('SARfariDB::X3dFeaturePositions')
        ->get_features( $c->stash->{fixed_px} );

    for my $mobile_px ( @{ $c->stash->{mobile_px} } ) {

        # Capture user pxs in $all_user_pxs_store
        push( @{$all_user_pxs_store}, $mobile_px );

        # Get mobile domain aln features
        $c->stash->{pdb_features}->{$mobile_px} =
            $c->model('SARfariDB::X3dFeaturePositions')
            ->get_features($mobile_px);
    }

    if ( $c->stash->{option} eq 'Download' ) {

        # forward to download
        $c->forward('download');

    }
    elsif ( $c->stash->{option} eq 'View' ) {

        # There maybe some selected ksdids
        if ( $c->stash->{ksdids} ) {
            my $seq_aln_rs =
                $c->model('SARfariDB::AlignmentPositions')
                ->search( { 'me.ksdid' => $c->stash->{ksdids} } );

            my $px_aln_rs =
                $c->model('SARfariDB::X3dAlignmentPositions')
                ->search( { 'me.px' => $c->stash->{fixed_px} } );

            my $px2seq_aln = {};
            my $gaps       = {};

            while ( my $seq = $seq_aln_rs->next ) {
                $px2seq_aln->{ $seq->aln_pos }->{seq}->{ $seq->ksdid } = {
                    "res"     => $seq->residue,
                    "seq_pos" => $seq->seq_pos
                };

                if ( $seq->residue eq "-" ) {
                    $gaps->{ $seq->aln_pos } = "gap";
                }
                else {
                    $gaps->{ $seq->aln_pos } = "no_gap";
                }
            }

            while ( my $str = $px_aln_rs->next ) {
                $px2seq_aln->{ $str->aln_pos }->{str}->{ $str->px } = {
                    "res"     => $str->residue,
                    "seq_pos" => $str->seq_pos,
                    "resnum"  => $str->pdb_resnum
                };

                if ( $str->residue eq "-" ) {
                    $gaps->{ $str->aln_pos } = "gap";
                }
                else {
                    $gaps->{ $str->aln_pos } = "no_gap";
                }
            }

            $c->stash->{gaps}       = $gaps;
            $c->stash->{px2seq_aln} = $px2seq_aln;
        }

        # Get all domain details
        $c->stash->{pdb_details} =
            $c->model('SARfariDB::X3dPdbDomain')
            ->get_structures_hash($all_user_pxs_store);
		
		$c->stash->{simple} = 1;
        $c->stash->{body}   = "structure/structure_astex.tt";
    }
    else {
        $c->detach( '/error/index',
            [ "Structure fit forwarding action not recognised", 1 ] );
    }
}


# Generate rotated pdb

sub pdblig : Regex('structure/pdblig/(\d+)$') {
    my ( $self, $c ) = @_;
    my ( $sarregno ) = @{ $c->request->snippets };

    # If no data retured give pseudo '-1' registration code, prevents 
	# exceptions in Search.pm
    $c->req->params->{'targetList'} = $sarregno || -1;
    $c->req->params->{'targetType'} = "pdblig";

    # Go to compound search
    $c->detach("/structure/search");
}

# Generate rotated pdb

sub generate : Regex('generate/(vanilla|ec_cbs|ec_ctl)/(\d+)_(\d+).pdb$') {
    my ( $self, $c ) = @_;
    my ( $fit_method, $ref_px, $mob_px ) = @{ $c->request->snippets };

    my $COMMON_VIEW_PX = 1292337;

    # Get structure
    my $dom      = $c->model('SARfariDB::X3dPdbDomain')->find($mob_px);
    my $pdb_file = Compress::Zlib::memGunzip( \$dom->domain_file );

    # Need to rotate structure if ref and mob diffrent
    if ( $ref_px != $mob_px ) {
        my $transform =
            $c->model('SARfariDB::X3dDomainFits')->find( $ref_px, $mob_px );
        my $rotated = _rotate( $pdb_file, $transform, $fit_method );
        $pdb_file = $$rotated;
    }

    # Create a common view so that all structures look the same
    # Applied to ref and mob(s)
    if ( $ref_px != $COMMON_VIEW_PX ) {
        my $transform_view =
            $c->model('SARfariDB::X3dDomainFits')
            ->find( $ref_px, $COMMON_VIEW_PX );
        my $rotated_view = _rotate( $pdb_file, $transform_view, $fit_method );
        $pdb_file = $$rotated_view;
    }

    $c->res->headers->content_type('chemical/x-pdb');
    $c->res->output($pdb_file);
}

# Create in memory zipped folder, which contains all superimposed structures

sub download : Private {
    my ( $self, $c ) = @_;

    # Create in memory file
    my $memory_archive = '';
    my $SH             = IO::String->new($memory_archive);

    # Create a zip archive
    my $zip = Archive::Zip->new();

    # Hold file names, used to create scripts
    my $filename_store = [];

    # Archive structure extensions
    my $FILE_EXTENSION = ".ent";

    # Get reference domain structure and add to archive
    my $rdom =
        $c->model('SARfariDB::X3dPdbDomain')->find( $c->stash->{fixed_px} );
    my $rfile = Compress::Zlib::memGunzip( \$rdom->domain_file );

    if ( $c->req->params->{'download_site'} > 0 ) {

        my $site_pos = $c->model('SARfariDB::X3dAlignmentPositions')->search(
            {   "me.px"             => $c->stash->{fixed_px},
                "site_defs.site_id" => $c->req->params->{'download_site'}
            },
            { join => [qw / site_defs /] }
        );

        my $site_pos_data = {};

        while ( my $ap = $site_pos->next ) {
            $site_pos_data->{ $ap->pdb_resnum } = $ap->aln_pos;
        }

        my $site_pos_rfile = _restrict_binding_site( $rfile, $site_pos_data );
        $rfile = $site_pos_rfile;
    }

    if ( $c->req->params->{'aln_pos'} eq "on" ) {
        my $aln_pos =
            $c->model('SARfariDB::X3dAlignmentPositions')
            ->search( "me.px" => $c->stash->{fixed_px} );

        my $aln_pos_data = {};

        while ( my $ap = $aln_pos->next ) {
            $aln_pos_data->{ $ap->pdb_resnum } = $ap->aln_pos;
        }

        my $aln_pos_rfile = _aln_pos_mod( $rfile, $aln_pos_data );
        $rfile = $aln_pos_rfile;
    }

    my $rfile_name =
        $c->stash->{fixed_px} . "\_" . $rdom->pdb_code . $FILE_EXTENSION;
    push( @{$filename_store}, $rfile_name );

    $zip->addString( $rfile, $rfile_name )
        ->desiredCompressionMethod(COMPRESSION_DEFLATED);

    # Add each mobile structure to archive
    foreach my $m ( @{ $c->stash->{mobile_px} } ) {
        my $transform =
            $c->model('SARfariDB::X3dDomainFits')
            ->find( $c->stash->{fixed_px}, $m );
        my $mdom     = $c->model('SARfariDB::X3dPdbDomain')->find($m);
        my $mfile    = Compress::Zlib::memGunzip( \$mdom->domain_file );
        my $mrotated = _rotate( $mfile, $transform, $c->stash->{fit_type} );

        if ( $c->req->params->{'download_site'} > 0 ) {

            my $site_pos =
                $c->model('SARfariDB::X3dAlignmentPositions')->search(
                {   "me.px"             => $m,
                    "site_defs.site_id" => $c->req->params->{'download_site'}
                },
                { join => [qw / site_defs /] }
                );

            my $site_pos_data = {};

            while ( my $ap = $site_pos->next ) {
                $site_pos_data->{ $ap->pdb_resnum } = $ap->aln_pos;
            }

            my $site_pos_mfile =
                _restrict_binding_site( $mrotated, $site_pos_data );
            $mrotated = $site_pos_mfile;
        }

        if ( $c->req->params->{'aln_pos'} eq "on" ) {
            my $aln_pos =
                $c->model('SARfariDB::X3dAlignmentPositions')
                ->search( "me.px" => $m );

            my $aln_pos_data = {};

            while ( my $ap = $aln_pos->next ) {
                $aln_pos_data->{ $ap->pdb_resnum } = $ap->aln_pos;
            }

            my $aln_pos_mfile = _aln_pos_mod( $mrotated, $aln_pos_data );
            $mrotated = $aln_pos_mfile;
        }

        my $mfile_name = "$m\_" . $mdom->pdb_code . $FILE_EXTENSION;
        push( @{$filename_store}, $mfile_name );

        $zip->addString( $mrotated, $mfile_name )
            ->desiredCompressionMethod(COMPRESSION_DEFLATED);
    }

    # Add pdb viewer scripts
    my $pymol_script = _create_pymol_script($filename_store);
    $zip->addString( $pymol_script, 'view_in_pymol.pml' )
        ->desiredCompressionMethod(COMPRESSION_DEFLATED);

    # Write out archive
    unless ( $zip->writeToFileHandle($SH) == AZ_OK ) {
        $c->detach( '/error/index', ["Error: Not able write zip archive"] ),;
    }

    # Appended to archive file name - this is only used to differentiate 
    # downloads
    my $archive_id = int( rand(10000) );

    $c->res->header( 'Content-Disposition',
        ["attachment; filename=ks_structures_$archive_id.zip"] );
    $c->res->content_type('application/zip');
    $c->res->body($memory_archive);
}


# Carry out structure rotation

sub _rotate {
    my ( $file, $transform, $fit ) = @_;

    # If no fit provided default to vanilla
    $fit = ( $fit || "vanilla" );

    my $mat_method  = "$fit\_rot_mat";
    my $cog_method  = "$fit\_cog";
    my $tran_method = "$fit\_translation";

    # Turn fit information into useful data structures
    my $ROTATE = [
        map { [ split( /,/, $_ ) ] }
            split( /\n/, $transform->$mat_method )
    ];
    my $COG       = [ split( /,/, $transform->$cog_method ) ];
    my $TRANSLATE = [ split( /,/, $transform->$tran_method ) ];

    # Return value
    my $rotated_pdb = \do { my $anon_scalar };

    # Break up file and loop each line
    my @lines = split( /\n/, $file );
    foreach my $l (@lines) {

        # PDB ATOM row format, defined:
        # http://deposit.rcsb.org/adit/docs/pdb_atom_format.html
        Readonly my $ATOM_LINE => qr { 
                    #COLUMNS        DATA TYPE       FIELD    
                    #-----------------------------------------
            (.{6}   # 1 -  6        Record name     "ATOM  "
             .{5}   # 7 - 11        Integer         serial   
             .      # -SPACEx1-
             .{4}   # 13 - 16       Atom            name     
             .{1}   # 17            Character       altLoc   
             .{3}   # 18 - 20       Residue name    resName  
             .      # -SPACEx1-   
             .{1}   # 22            Character       chainID  
             .{4}   # 23 - 26       Integer         resSeq   
             .{1}   # 27            AChar           iCode    
             ... )  # -SPACEx3-
            (.{8})  # 31 - 38       Real(8.3)       x        
            (.{8})  # 39 - 46       Real(8.3)       y        
            (.{8})  # 47 - 54       Real(8.3)       z        
            (.{6}   # 55 - 60       Real(6.2)       occupancy
             .{6}   # 61 - 66       Real(6.2)       tempFactor
             .{6}   # -SPACEx6-
             .{4}   # 73 - 76       LString(4)      segID    
             .{2}   # 77 - 78       LString(2)      element  
             .{2})  # 79 - 80       LString(2)      charge   
        }xs;

        if ( $l =~ /^ATOM|^HETATM/ ) {
            my ( $precoord, $x, $y, $z, $postcoords ) = $l =~ $ATOM_LINE;

            my $x_origin = $x - $COG->[0];
            my $y_origin = $y - $COG->[1];
            my $z_origin = $z - $COG->[2];

            my $X_roto =
                ( $x_origin * $ROTATE->[0][0] ) +
                ( $y_origin * $ROTATE->[0][1] ) +
                ( $z_origin * $ROTATE->[0][2] );

            my $Y_roto =
                ( $x_origin * $ROTATE->[1][0] ) +
                ( $y_origin * $ROTATE->[1][1] ) +
                ( $z_origin * $ROTATE->[1][2] );

            my $Z_roto =
                ( $x_origin * $ROTATE->[2][0] ) +
                ( $y_origin * $ROTATE->[2][1] ) +
                ( $z_origin * $ROTATE->[2][2] );

            my $new_x = $X_roto + $COG->[0] + $TRANSLATE->[0];
            my $new_y = $Y_roto + $COG->[1] + $TRANSLATE->[1];
            my $new_z = $Z_roto + $COG->[2] + $TRANSLATE->[2];

            $$rotated_pdb .= "$precoord"
                . sprintf( "%8s", sprintf( "%.3f", $new_x ) )
                . sprintf( "%8s", sprintf( "%.3f", $new_y ) )
                . sprintf( "%8s", sprintf( "%.3f", $new_z ) )
                . "$postcoords\n";
            next;
        }

        # If not ATOM/HETATM line just add with no modification
        $$rotated_pdb .= "$l\n";
    }
    return $rotated_pdb;
}

# Create simply script which launches and loads structures in to pymol

sub _create_pymol_script{
    my($structure_files) = @_;

    my $pymol_script;
    
    if(scalar($structure_files) > 0){
        
        my $code_store = [];
        
        for my $file_name (@{$structure_files}) {
            my $code = $file_name;
            $code =~ s/\..*?$//;#r emove file extension
            push(@{$code_store},$code);
            $pymol_script .=  "load $file_name\ncreate $code\_ligand, hetatm & $code & ! resn hoh\n";
        }
    
        # display...
        $pymol_script .= "hide all\nshow ribbon, all\n";
                
        for my $code (@{$code_store}) {
            $pymol_script .=  "show sticks, $code\_lig\n";        
        }
    }
    
    return $pymol_script;
}


1;
