#!/usr/bin/perl

use strict;
use DBI;
use FindBin;
my $cwd=$FindBin::Bin;
use POSIX;
# BEGIN: APPRIS -> IMPORTANT -> COMMENTED TEMPORALLY
# use Mail::Sender;
# END: APPRIS -> IMPORTANT -> COMMENTED TEMPORALLY
use Config::IniFiles;

# BEGIN: APPRIS
require "$cwd/FUNCTIONS.pl";
#require "$cwd/SSH.pm";
#require "$cwd/SSH1.pm";
require "$cwd/CP1.pm";
# END: APPRIS

# BEGIN: APPRIS -> IMPORTANT
my $tmpfile=$ARGV[0];
my $queryname=$ARGV[1];
my $sequence=$ARGV[2];
my $evalue=$ARGV[3];
my $outfile=$ARGV[4];
my $cutoff=$ARGV[5];
my $csa_option=$ARGV[6];
my $cognate_option=$ARGV[7];
my $OPTION=undef;
my $CASP_mail=undef;
my $conf_file="$cwd/../CONFIG_fire_var.ini";
if (defined $ARGV[8]) { $OPTION=$ARGV[8]};
if (defined $ARGV[9]) { $CASP_mail=$ARGV[9]};
if (defined $ARGV[10]) { $conf_file=$ARGV[10]};

my $variables=Config::IniFiles->new( -file => $conf_file );
# END: APPRIS

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#       Prueba de conexion con base de datos
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
my $dbHost=$variables->val('MYSQL','dbHost');
my $dbName=$variables->val('MYSQL','dbName');
my $user=$variables->val('MYSQL','user');
my $pass=$variables->val('MYSQL','pass');
my $sth;                #objeto DBI
my $dataHandle = DBI->connect("DBI:mysql:database=$dbName;host=$dbHost","$user","$pass",{RaiseError => 1,AutoCommit =>0})
                                || die "Unable to connect to $dbName because $DBI::errstr";
my $serverInfo = $dataHandle->{'mysql_serverinfo'};
my $serverStat = $dataHandle->{'mysql_stat'};
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

my $home=$variables->val('PATHS','home');
my $server=$variables->val('SERVER','srv');
my @trash=split(/\./,$server);
$server=$trash[0];

# BEGIN: APPRIS
#my $temporal="$home/tmp/faatmp";
#my $afmpath="$home/Square/another_fire_mess_web";
my $temporal=$variables->val('PATHS','tmp');
my $afmpath=$variables->val('PATHS','AFM');
# END: APPRIS

my $makemat=$variables->val('PROGRAMS','bstbin');$makemat.="/makemat";
my $nrdb=$variables->val('DATABASES','nrdb');
my $release_date=$variables->val('DATABASES','release');                # ojo con esto, cada vez que se actualiza fireDB cambia

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

my $cutPercentage=24.99;
my $cutPercentage_metal=49.99;
my $cutPercentage_csa=65.99;
my $hit_mean_cutoff=1;				# pej 1
my $hit_score_cutoff=3;				# pej 4
my $clust_cut1=0.6;				# pej 0.4
my $clust_cut2=0.6;				# pej 0.4
my $relative_num_of_cases=0;			# pej 0.01
my $residue_score_metal=3;			# pej 3  - valor minimo de square para aceptar un residuo (en metal site)
my $residue_score_no_metal=2;			# pej 3  - valor minimo de square para aceptar un residuo (en no-metal site)
my $absolute_afm_score_metal=1;			# pej 1  - valor de conservacion de un site respecto al alineamiento (en metal site)
my $absolute_afm_score_no_metal=1;		# pej 1  - valor de conservacion de un site respecto al alineamiento (en no-metal site)
my $clustered_residue_freq=0.3;			# pej 0
my $residue_score_csa=3;
my %site_score;                                 # en este hash se guardan todos los parametros para dar un score al site:
						# RANKING (PSI o HHS) del mejor template, Coverage, 
						# numero de Homologos, y SQUARE's score de los aa predichos en el site
my @num_of_sites;
my %global_SQUARE_MEAN;			###     TRASHi
my %psiout;	# contiene el output de psi blast parseado (es un hash de array)
my %psidone;	# se recopilan los psiblast que ya se han corrido
my %cognate;		# aqui se guarda la informacion acerca de los cognate ligands
my %poss_cognate;	# aqui se guarda la informacion acerca de los possibles cognate ligands
my %metals;		# aqui se guarda la informacion acerca de los metales

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


my $tmpfile=$ARGV[0];
my $queryname=$ARGV[1];
my $sequence=$ARGV[2];
my $evalue=$ARGV[3];
my $outfile=$ARGV[4];
my $cutoff=$ARGV[5];
my $csa_option=$ARGV[6];

#open(STDERR,'>',"/tmp/logpred-$$.txt");
#select STDERR;
#$|=1;
#select STDOUT;
#print STDERR join("\n",@ARGV);

if (defined $cutoff){
	if ($cutoff=~/NO/){$cutoff=undef;}
	elsif ($cutoff!~/\d+/){$cutoff=0;}
}
else {$cutoff=0;}
if (defined $csa_option){$csa_option=uc($csa_option);}
else {$csa_option="YES";}
my $cognate_option=$ARGV[7];
unless (defined $cognate_option){$cognate_option="YES";}

#open(LOG,">$cwd/../tmp/faatmp/$tmpfile.logger.txt");
#print LOG "CUT-OFF: #$cutoff#\tCSA_OPTION: #$csa_option#\tCOGNATE_OPTION: #$cognate_option#\n";

#die;


my $OPTION=undef;					## APPRIS CHANGE ##
if (defined $ARGV[8]){$OPTION=$ARGV[8];}		## APPRIS CHANGE ##


my $CASP_mail=undef;
my $remitente=undef;
my $cabecera;
my $subject_CASP="firestar prediction $queryname";
# BEGIN: APPRIS -> IMPORTANT 
#if (defined $ARGV[9] && $OPTION eq "CASP"){			## CASP CHANGE ##
if (defined $CASP_mail && $OPTION eq "CASP"){
# END: APPRIS -> IMPORTANT 
	$cutoff=50;
	$cabecera="PFRMAT FN\nTARGET $queryname\nAUTHOR 5640-6902-4972\nREMARK ####\nMETHOD inference from sequence homology \nMODEL  1\n";
	$CASP_mail=$ARGV[9];	## CASP CHANGE ##
	$remitente='firestar@bioinfo.cnio.es';
	$outfile="$cwd/../tmp/CASP_results/$queryname.txt";	## CASP CHANGE ##
}								## CASP CHANGE ##

# BEGIN: APPRIS
##my $sender=new Mail::Sender {from => $remitente,to => $CASP_mail,bcc => 'pmaietta@cnio.es',replyto => 'pmaietta@cnio.es'};
#my $sender=new Mail::Sender {from => $remitente,to => 'mtress@cnio.es',bcc => 'pmaietta@cnio.es',replyto => 'pmaietta@cnio.es'};
unless ($OPTION eq "appris"){
	#my $sender=new Mail::Sender {from => $remitente,to => $CASP_mail,bcc => 'pmaietta@cnio.es',replyto => 'pmaietta@cnio.es'};
	my $sender=new Mail::Sender {from => $remitente,to => 'mtress@cnio.es',bcc => 'pmaietta@cnio.es',replyto => 'pmaietta@cnio.es'};
}
# END: APPRIS

my %pred_sites_list;
my %all_res;
my %all_csite_res;
my %score_app;
my %all_bind_res;
my %all_csite_info;
my %all_bind_res_ids;
my %pocket2bind;

my %all_met_res;
my %all_nom_res;
my %all_nom_nocog_res;

my %all_csite_score;
my %all_csite_aa;
my %all_csite_TAG;
my %all_csite_coverage;
my %all_csite_mean;

##########      CSA EVALUATION  ###########
##########      FOR EVERYONE    ###########
my %all_csa_res;
my %all_csa_score;
my %csa_res_freq;
##########      OVER 30 ###################
my %all_csa_res_30;
my %all_csa_score_30;
my %csa_res_freq_30;
##########      OVER 60 ###################
my %all_csa_res_60;
my %all_csa_score_60;
my %csa_res_freq_60;
##########      GLOBAL VARS     ###########
my %all_csa_aa;
my %csa_sites;
###########################################
	
my %summary_csa;
my %summary;
my $autoincr=0;
my %summary_order;
my $longest_alignment_cutoff=0;

my %ec2go;
my %cif2go;
readlib();
#open(TRASH,">trash.txt");
#open(TRASH2,">trash2.txt");
#my $tmpchads="$vars{squareDir}/tmpchads";
# BEGIN: APPRIS -> IMPORTANT
#my $faatmp="$cwd/../tmp/faatmp";
# END: APPRIS -> IMPORTANT

run_psiblast($tmpfile,$sequence,$evalue);
parse_psiblast($tmpfile,$evalue);
# BEGIN: APPRIS
#unless ($OPTION eq "appris" && length($sequence)>250){parse_hhsearch($tmpfile,"Query");}
parse_hhsearch($tmpfile,"Query");
# END: APPRIS
psi_output_generator($tmpfile,"faa","0","0");

# Conservacion de la secuencia query


%all_csite_res=%all_met_res;
my @met=residue_clustering();
my @clustered_csites=@met;


%all_csite_res=%all_nom_res;
my @nom=residue_clustering();
push(@clustered_csites,@nom);

%all_csite_res=%all_nom_nocog_res;
my @nom_nocog=residue_clustering();
push(@clustered_csites,@nom_nocog);

my @seq=split(//,$sequence);
my $query_pos=0;

#######################################################         CSA PART [begin]        #############################################################
if (scalar(keys%all_csa_res_60)>5){
        %all_csa_res=%all_csa_res_60;
        %all_csa_score=%all_csa_score_60;
        %csa_res_freq=%csa_res_freq_60;
}
elsif(scalar(keys%all_csa_res_30)>15){
        %all_csa_res=%all_csa_res_30;
        %all_csa_score=%all_csa_score_30;
        %csa_res_freq=%csa_res_freq_30;
}

# Aqui 

#my @driver;		# los valores de este array definen el numero y longitud de las lineas
#my $seq_len=length$sequence;
#set_driver($seq_len);
# Sitios cataliticos (CSA)
my %csa_res;
my %csa_res_aa;
foreach my $csiteid(keys%all_csa_res){          ## este es un bucle para clusterizar los CSA, ya que no se ha hecho antes con la subrutina
        my $key_res=$all_csa_res{$csiteid};     ## residue_clustering !!!!
        my @csa_res=split(/ /,$key_res);        ## en este array estan todas las posiciones de los aa en la sec query
	my @csa_res_ord=sort@csa_res;
        my $all_aa;
        my $new_string;
        foreach my$num(@csa_res_ord){
                if ($num ne '' && $new_string eq ''){$new_string="$num";}
                elsif($num ne ''){$new_string.=" $num";}
                $all_aa=$all_aa.$all_csa_aa{$num};      ## en $all_aa guardamos todos los aa, codigo de una letra
        }
#       $csa_res_aa{$key_res}=$all_aa;          ## en este hash CLAVE: "23 45 75 .." VALOR: "A K C .."
#       foreach my$num(@csa_res){               ### bucle en mi opinion inutil ... no se vuelve a usar $all_aa
#               $all_aa=$all_aa.$all_csite_aa{$num};
#               }
        if(exists$csa_sites{$new_string}){              ## generamos un hash con CLAVE: "23 45 75 .." y VALOR: el Cat. Site ID
                $csa_sites{$new_string}="$csa_sites{$new_string} $csiteid";
        }
        else{$csa_sites{$new_string}=$csiteid;}
}

my $conteur=0;
my $flag2="RED";
while ($flag2 eq "RED"){
        my $change="ON";
        foreach my $csa_block (keys%csa_sites){
                $conteur++;
                my $csa_block2;
                my @key_res2;
                my @key_res=split(/ /,$csa_block);
                foreach $csa_block2 (keys%csa_sites){
                	my $iguales=0;
                        if ($csa_block2 eq $csa_block or $csa_block2 eq ''){next;}
                        @key_res2=split(/ /,$csa_block2);
                        foreach my $iii(@key_res){
                                foreach my $aaa(@key_res2){
                                        if ($iii==$aaa){$iguales++;}
                                }
                        }
                        if ($iguales==scalar@key_res && defined $csa_block){
                                $csa_sites{$csa_block2}.=" $csa_sites{$csa_block}";
                                delete$csa_sites{$csa_block};
                                $change="OFF";
                                last;
                        }
			if (scalar@key_res < scalar@key_res2 && $iguales/scalar@key_res >= 0.33){
				my %common;
				foreach my $iii(@key_res){$common{$iii}=5;}
				foreach my $iii(@key_res2){$common{$iii}=5;}
				my $new_block=join(' ',sort(keys%common));
				$csa_sites{$new_block}=$csa_sites{$csa_block2}." ".$csa_sites{$csa_block};
				delete$csa_sites{$csa_block};
				delete$csa_sites{$csa_block2};
                                $change="OFF";
                                last;
                        }
                }
		if ($change eq "OFF"){last;}
        }
        if ($change eq "ON"){$flag2="GREEN";}
}

my $csaincr=0;                  # este valor se autoincrementa para cada sitio catalitico predicho
my %csa_clust;
my %all_csa;
foreach my $key_res(keys%csa_sites){
        my %csa;
        my @spl=split(/ /,$key_res);
        my @csiteids=split(/ /,$csa_sites{$key_res});
        foreach my $csiteid(@csiteids){
		my @new_spl=split(/ /,$all_csa_res{$csiteid});
                my @scores=split(//,$all_csa_score{$csiteid});
                for(my$i=0;$i<$#new_spl+1;$i++){
                        my $num=$new_spl[$i];
			if ((exists$csa{$num} && $scores[$i]>$csa{$num}) || !exists$csa{$num}){$csa{$num}=$scores[$i];}
                }
                my $clustid=$all_csite_info{$csiteid};  ## solo para CSA $all_csite_info{$csiteid} contiene el clustid; normalmente hay compuestos 
                $sth = $dataHandle -> prepare("select EC1,EC2,EC3 from INFOACC where CADID=\"$clustid\"");      ## recuperamos informacion de EC
                $sth -> execute();
                my @ec = $sth -> fetchrow_array();
                $sth -> finish();
                for(@ec){                       ## aqui por cada numero EC recuperamos cadenas asociadas almacenadas en FireDB
                        my $ec=$_;
                        $sth = $dataHandle -> prepare("select CSANOTE from SITE35 where CADID=\"$clustid\" and SITETYPE=\"CSA\"");
                        $sth -> execute();
                        my $csanote= $sth -> fetchrow_array();
                        $csa_clust{$clustid}=$csanote;
                        $sth -> finish();
                }
        }
	##########################
	##      FREQ FILTER     ##
	##########################
	my @score_here;
	foreach (@spl){push(@score_here,$csa_res_freq{$_});}
	my @ord_score=sort { $b <=> $a } @score_here;
	my $beast=$ord_score[0];
	##########################
        $query_pos=0;
        $csaincr++;
        for(@seq){                      ## en este bucle se pasa por toda la secuencia y se guarda en el hash %summary_csa toda la informacion de
                if($_ ne "-"){          ## posicion, nombre, etc etc. 
                        $query_pos++;
                        if(exists$csa{$query_pos} && $csa_res_freq{$query_pos}/$beast > 0.50){
				if (exists $summary_csa{resnum}[$csaincr]){
					$summary_csa{resnum}[$csaincr]="$summary_csa{resnum}[$csaincr] $query_pos";
					$summary_csa{resname}[$csaincr]="$summary_csa{resname}[$csaincr]$_";
					$summary_csa{score}[$csaincr]="$summary_csa{score}[$csaincr]$csa{$query_pos}";
					$all_csa{$query_pos}=5;
				}
				else {
					$summary_csa{resnum}[$csaincr]="$query_pos";
					$summary_csa{resname}[$csaincr]=$_;
					$summary_csa{score}[$csaincr]=$csa{$query_pos};
					$all_csa{$query_pos}=5;
				}
			}
		}
	}
	if ($key_res ne $summary_csa{resnum}[$csaincr]){$csa_sites{$summary_csa{resnum}[$csaincr]}=$csa_sites{$key_res};delete$csa_sites{$key_res};}
}
#######################################################		CSA PART [end]		#############################################################

my %all_site_res;
my $hitNumOfSites=0;
for(@clustered_csites){
	my @spl=split(/ /,$_);
	my $tmpcases=scalar@spl;
	if($hitNumOfSites < $tmpcases){$hitNumOfSites = $tmpcases;}
}
my $numbering_filtered_residues;
$longest_alignment_cutoff=ceil($longest_alignment_cutoff/2);

for(@clustered_csites){
	my $ids=$_;
	my @spl=split(/ /,$_);
	my $numberOFsites=scalar@spl;
	my $all_res;
	my %all_aa=();
	my %compids=();
	my $hit_score=0;
	my $hit_mean=0;
	my %res=();
	my %all_scorez=();
	my %well60=();
	my %well35=();
	my $res_hit=1;
	my $res_hit_gold60=1;
	my $res_hit_gold35=1;
	my $res_cut_off=0.1;
	my $posit_score;
	my @position_array;
	my @score_identit;
	my @gold_duo;
	my @biggest_length_ever;			###     TRASH
	my $site_length;				###     TRASH
	my %global_SQUARE_best_score;			###     TRASH
	my $FINAL_SQUARE_SCORE_COMBO;			###     TRASH
	my $global_clus_pred_tag;			###	TRASH
	my $coverage_tag;

	foreach my$id(@spl){
		my @alignment=split (/_/,$id);
		push (@position_array,$alignment[1]);
		my @res;
		if(exists$all_met_res{$id}){@res=split(/ /,$all_met_res{$id});$coverage_tag="MET";}
		elsif(exists$all_nom_res{$id}){@res=split(/ /,$all_nom_res{$id});$coverage_tag="NO_MET";}
		elsif(exists$all_nom_nocog_res{$id}){@res=split(/ /,$all_nom_nocog_res{$id});$coverage_tag="NO_MET";}
		my @tempora=split(/ /,$score_app{$id});
		my %scorez;
		foreach (@tempora){
			if ($_=~/(\d+)\((\d)\)/){$scorez{$1}=$2;}
		}
		my @temporal=split(/_/,$id);
		my $alig=$temporal[1];
		my $q_start=$psiout{$alig}[4];           # coordenada absoluta del primer aminoacido de la query en este alineamiento
		my $q_end=$psiout{$alig}[5];             # coordenada absoluta del ultimo aminoacido de la query en este alineamiento
		my $length_ali=$q_end-$q_start+1;
		######################################################################################################################
		# En esta nueva parte del programa damos un peso diferente a los residuos, que depende de la frecuencia relativa de  #
		# aparicion en los alineamientos y del tipo de alineamiento. Si unos residuos resultan aparecer en alineamientos con #
		# e-value bueno y % de identidad alto (> 60 o > 35) tendran un peso mayor en la prediccion respecto a los demas.     #
		######################################################################################################################
		if ($psiout{$alig}[10] eq "PSI" && ($psiout{$alig}[9]==0 || $psiout{$alig}[9]=~/e\-(\d+)/)){
                        my $evalor;
                        my $identit=0;
                        if ($psiout{$alig}[9]=~/e\-(\d+)/){$evalor=sprintf("%.10f", $psiout{$alig}[9]);}
                        if ($psiout{$alig}[8]=~/\d+\/\d+\s+\((\d+)%\)/){$identit=$1;}
                        if ($psiout{$alig}[9]!=0 && $evalor>0.005){$identit=20;}
                        push (@score_identit,$identit);
                        if ($identit>59 && $length_ali>=$longest_alignment_cutoff){
                                $res_cut_off=0.25;
                                foreach my $res(@res){
                                        if(exists $well60{$res}){
                                                $well60{$res}++;
                                                if($well60{$res}>$res_hit_gold60){$res_hit_gold60=$well60{$res};}
                                        }
                                        else{$well60{$res}=1;}
                                }
                        }
                        elsif (scalar(keys%well60)==0 && $identit>=30 && $length_ali>=$longest_alignment_cutoff){
                                $res_cut_off=0.25;
                                foreach my $res(@res){
                                        if(exists $well35{$res}){
                                                $well35{$res}++;
                                                if($well35{$res}>$res_hit_gold35){$res_hit_gold35=$well35{$res};}
                                        }
                                        else{$well35{$res}=1;}
                                }
                        }
                }
                elsif ($psiout{$alig}[10] eq "PSI" && $psiout{$alig}[8]=~/\d+\/\d+\s+\((\d+)%\)/){
                        my $identit=$1;
                        if ($psiout{$alig}[9]>0.005){push (@score_identit,20);}
                        else {push (@score_identit,$identit);}
                }
                elsif ($psiout{$alig}[10] eq "HHS" && ($psiout{$alig}[9]==0 || $psiout{$alig}[9]=~/e\-(\d+)/)){
                        my $identit=0;
                        my $evalor;
                        if ($psiout{$alig}[9]=~/e\-(\d+)/){$evalor=sprintf("%.10f", $psiout{$alig}[9]);}
                        if ($psiout{$alig}[8]=~/Identities=(\d+)%,/){$identit=$1;}
                        if ($psiout{$alig}[9]!=0 && $evalor<0.005){$identit=20;}
                        push (@score_identit,$identit);
                        if ($identit>59 && $length_ali>=$longest_alignment_cutoff){
                                $res_cut_off=0.25;
                                foreach my $res(@res){
                                        if(exists $well60{$res}){
                                                $well60{$res}++;
                                                if($well60{$res}>$res_hit_gold60){$res_hit_gold60=$well60{$res};}
                                        }
                                        else{$well60{$res}=1;}
                                }
                        }
                        elsif (scalar(keys%well60)==0 && $identit>=30 && $length_ali>=$longest_alignment_cutoff){
                                $res_cut_off=0.25;
                                foreach my $res(@res){
                                        if(exists $well35{$res}){
                                                $well35{$res}++;
						if($well35{$res}>$res_hit_gold35){$res_hit_gold35=$well35{$res};}
                                        }
                                        else{$well35{$res}=1;}
                                }
                        }
                }
                elsif ($psiout{$alig}[10] eq "HHS" && $psiout{$alig}[8]=~/Identities=(\d+)%,/){
                        my $identit=$1;
                        if ($psiout{$alig}[9]<0.005){push (@score_identit,20);}
                        else {push (@score_identit,$identit);}
                }
	#	if ($coverage_tag eq "MET"){$res_cut_off=0.33;}		#####	CASP10 change for metal !!
		#############################################	[END]	###########################################################
		foreach my$res(@res){
			if(exists$res{$res}){	### generamos un hash %res con CLAVE: pos absoluta del residuo y VALOR: el numero de veces que aparece
				if ($length_ali>=$longest_alignment_cutoff){$res{$res}++;}  ## en los clusters 
				if($res{$res}>$res_hit){$res_hit=$res{$res};}	## $res_hit es un umbral del numero de veces que aparece un residuo
			}
			else{$res{$res}=1;}
			if(exists$res{$res} && $all_scorez{$res}<$scorez{$res}){$all_scorez{$res}=$scorez{$res};}
			else{$all_scorez{$res}=$scorez{$res};}
			if (exists $global_SQUARE_best_score{$res}){
				if ($global_SQUARE_best_score{$res}<${$global_SQUARE_MEAN{$id}}{$res}){
					$global_SQUARE_best_score{$res}=${$global_SQUARE_MEAN{$id}}{$res};
				}
			}
			else {
				$global_SQUARE_best_score{$res}=${$global_SQUARE_MEAN{$id}}{$res};
			}
		}
		my @comps=split(/ /,$all_csite_info{$id});	### aqui recuperamos todos los compuestos que hacen binding con el site
		$global_clus_pred_tag=$all_csite_TAG{$id};
		foreach my$compid(@comps){
			my @spl=split(/\(/,$compid);
			$spl[1]=~s/\)//;
			$compid=$spl[0];
			if(exists$compids{$compid}){$compids{$compid}++;}	### aqui contamos cuantas veces aparece un mismo compuesto en todos los
			else{$compids{$compid}=1;}				### los sitios cataliticos clusterizados juntos
		}
		if($hit_score < $all_csite_mean{$id}){		## aqui guardamos la media del score de SQUARE de los aa del site mas alta entre
			$hit_score = $all_csite_mean{$id};	## todos los sitios clusterizados juntos !!
			$gold_duo[0]=$hit_score;
		}
		push(@biggest_length_ever,$all_csite_coverage{$id});
		if($hit_mean < $all_csite_score{$id}){		## aqui guardamos el score mas alto entre los sites, calculado antes como la media de 
			$hit_mean = $all_csite_score{$id};	## los scores de los aa del site/media de los scores de todos los aa de la sec
		}						## en el alineamiento de donde se saco el site
	}
	my $corrector_HHS;
	my $flag="GREEN";
	foreach my $k (sort { $a <=> $b} keys %psiout){
		if ($psiout{$k}[10] eq "HHS" && $flag eq "GREEN"){
			$corrector_HHS=$k-1;
			$flag="RED";
			last;
		}
	}
	$numbering_filtered_residues=0;
	############### CHANGE in the CALCULATION OF THE COVERAGE OF THE SITE ##############
	## Aquí estamos calculando el promedio de la longitud de los sites que se han usado#
	## para obtener la prediccion de estos residuos 
	my $mean_site_length;
	foreach my $x (@biggest_length_ever){
		$mean_site_length=$mean_site_length+$x;
	}
	if ($coverage_tag ne "MET"){
		$mean_site_length=$mean_site_length/scalar@biggest_length_ever;
	}
	else {
		my @ord=sort{$b<=>$a}(@biggest_length_ever);
		$mean_site_length=$ord[0];
	}
	$gold_duo[1]=$mean_site_length;
	###################################################################################
	my @ordered_identit=sort { $b <=> $a} @score_identit;
	my $best_alignment_position=3000;
	foreach my $z (@position_array){
		if ($z>$corrector_HHS){$z=$z-$corrector_HHS;}
		if ($z<$best_alignment_position){$best_alignment_position=$z;}
	}
	
	if($numberOFsites/$hitNumOfSites > $relative_num_of_cases and $hit_mean >= $hit_mean_cutoff and $hit_score > $hit_score_cutoff){
#	aqui tenemos 3 filtros: el primero es una comparacion entre el tamano del cluster actual y el tamano del cluster mas grande (calculado antes). 
#	Este tiene que ser mayor de un umbral pre-establecido (ahora 0).
#	El segundo establece que la mejor media de los Scores de SQUARE de los sites del cluster tiene que superar un umbral pre-establecido (ahora 1).
#	El tercero compara el mejor score de todos los sites con un umbral pre-establecido (ahora 3).
		$autoincr++;
		push(@{$site_score{$autoincr}},$ordered_identit[0],$gold_duo[0],$gold_duo[1]);
		$summary{"numOfSites"}[$autoincr]=$numberOFsites;
		push(@num_of_sites,$numberOFsites);
		$summary{"score"}[$autoincr]=$hit_mean;
		if(exists$summary_order{$numberOFsites}){$summary_order{$numberOFsites}="$summary_order{$numberOFsites} $autoincr"}
		else{$summary_order{$numberOFsites}="$autoincr";}
#	$autoincr es la clave de acceso a las informaciones que se guardan del cluster; en este %summary_order se guardan como CLAVE: el numero de
#	sites en el clusters y VALOR: el $autoincr.
		my %comp_freq;
		foreach my$compid(keys%compids){
			my $freq=$compids{$compid};
			if(exists$comp_freq{$freq}){$comp_freq{$freq}="$comp_freq{$freq} $compid";}
			else{$comp_freq{$freq}=$compid;}
		}
#	en este hash %comp_freq la CLAVE es el numero de veces que aparece un compuesto en contacto en los sites y el VALOR es el nombre de los
#	compuestos con esa frecuencia
		my @all_comp;
		my @freqs=sort{$b<=>$a}(keys%comp_freq);
		foreach my$freq(@freqs){
			my @spl=split(/ /,$comp_freq{$freq});
			for(@spl){
				push(@all_comp,"$_($freq)");	
			}
		}
		my $all_comp=join(" ",@all_comp);
#	en la variable $all_comp se guardan todos los compuestos del cluster ordenados de mayor a menor frecuencia en el formato nombre(frec)

		##########################	GIVING MORE WEIGHT TO WELL CONSERVED RESIDUES	###############################
		my %all_res_freq=();
		my %well;
		my $res_hit_gold;
		if (scalar(keys%well60)!=0){%well=%well60;$res_hit_gold=$res_hit_gold60;}
		elsif(scalar(keys%well35)!=0){%well=%well35;$res_hit_gold=$res_hit_gold35;}
		foreach my $num(keys%res){
			if (exists $well{$num}){
				my $good_freq=$well{$num}/$res_hit_gold;
				my $norm_freq=$res{$num}/$res_hit;
				$all_res_freq{$num}=($good_freq+$norm_freq)/2;
			}
			else{$all_res_freq{$num}=$res{$num}/($res_hit+$res_hit_gold);} 
								### aqui normalizamos la frecuencia de aparicion de todos los residuos:
		}						### dividimos el numero de veces que aparece por el numero max de veces que 
								### aparece un res en el cluster
		###################################      GIVING MORE WEIGHT [END]     #########################################
		#################	SELECTION OF THE COMPOUND BASED ON THE "GENERAL TYPE" OF THE SITE	###############
		my @compid;
		my $first_poss;
                my $flag_poss_cog="DOWN";
                my $flag_cog="DOWN";
                for (my $xy=0;$xy<scalar@all_comp;$xy++){
                        @compid=();
                        @compid=split(/\(/,$all_comp[$xy]);     ## aqui elegimos el compuesto que esta haciendo binding (el que aparezca
                        $compid[1]=~s/\)//;                     ## mas veces haciendo binding en los CSITES
                        if (exists $metals{$compid[0]}){last;}
                        if ($global_clus_pred_tag eq "YES" && exists $cognate{$compid[0]}){
                                $flag_cog="UP";
                                last;
                        }
                        elsif ($global_clus_pred_tag eq "YES" && exists $poss_cognate{$compid[0]} && $flag_poss_cog eq "DOWN"){
                                $first_poss=$compid[0];
                                $flag_poss_cog="UP";
                        }
                        elsif ($global_clus_pred_tag eq "NON" && !exists $cognate{$compid[0]}){last;}
                }
                if ($global_clus_pred_tag eq "YES" && $flag_cog eq "DOWN"){$compid[0]=$first_poss;}
		################################################	[END]		#######################################
		###################################
		$sth = $dataHandle -> prepare("select NAME from COMPOUND where COMPID=\"$compid[0]\"");
		$sth -> execute();
		my $compname = $sth -> fetchrow_array();
		$sth -> finish();
		################# BIG CHANGE #################		aqui hacemos un tagging del compuesto mas frecuente COG/NO CO/POSS COG)
		if(exists $metals{$compid[0]} && exists $poss_cognate{$compid[0]}){
			$summary{"nice_try"}[$autoincr]="POSSIBLE_COGNATE";
			$summary{"type"}[$autoincr]="MET_POSS";
		}
		elsif (exists$poss_cognate{$compid[0]}){
			$summary{"nice_try"}[$autoincr]="POSSIBLE_COGNATE";
			$summary{"type"}[$autoincr]="NOM";
		}
		elsif (exists $metals{$compid[0]}){$summary{"nice_try"}[$autoincr]="COGNATE";$summary{"type"}[$autoincr]="MET";}
		elsif (exists $cognate{$compid[0]}){$summary{"nice_try"}[$autoincr]="COGNATE";$summary{"type"}[$autoincr]="NOM_COG";}
		else {$summary{"nice_try"}[$autoincr]="NON_COGNATE";$summary{"type"}[$autoincr]="NOM";}
		$summary{"compid"}[$autoincr]=$all_comp;
		$summary{"compname"}[$autoincr]=$compname;		
		################# BIG CHANGE #################	[END]
		$query_pos=0;
## este bucle enorme es para comprobar la ventana de conservacion del intorno del residuo predicho. Si este se encuentra en una zona muy poco
## conservada del alineamiento, se quita !!
		for(@seq){
			if($_ ne "-"){
				$query_pos++;
				if(exists$all_res_freq{$query_pos} and $all_res_freq{$query_pos} ne "none"){
					my $qpos_plus1=$query_pos+1;
					my $qpos_plus2=$query_pos+2;
					my $qpos_plus3=$query_pos+3;
					my $qpos_plus4=$query_pos+4;
					my $qpos_mnus1=$query_pos-1;
					my $qpos_mnus2=$query_pos-2;
					my $qpos_mnus3=$query_pos-3;
					my $qpos_mnus4=$query_pos-4;
					my $relative_freq=1;
					if(exists$all_res_freq{$qpos_plus1} and $relative_freq > $all_res_freq{$query_pos}/$all_res_freq{$qpos_plus1}){
						$relative_freq=$all_res_freq{$query_pos}/$all_res_freq{$qpos_plus1};
						}
					if(exists$all_res_freq{$qpos_plus2} and $relative_freq > $all_res_freq{$query_pos}/$all_res_freq{$qpos_plus2}){
						$relative_freq=$all_res_freq{$query_pos}/$all_res_freq{$qpos_plus2};
						}
					if(exists$all_res_freq{$qpos_plus3} and $relative_freq > $all_res_freq{$query_pos}/$all_res_freq{$qpos_plus3}){
						$relative_freq=$all_res_freq{$query_pos}/$all_res_freq{$qpos_plus3};
						}
					if(exists$all_res_freq{$qpos_plus4} and $relative_freq > $all_res_freq{$query_pos}/$all_res_freq{$qpos_plus4}){
						$relative_freq=$all_res_freq{$query_pos}/$all_res_freq{$qpos_plus4};
						}
					if(exists$all_res_freq{$qpos_mnus1} and $relative_freq > $all_res_freq{$query_pos}/$all_res_freq{$qpos_mnus1}){
						$relative_freq=$all_res_freq{$query_pos}/$all_res_freq{$qpos_mnus1};
						}
					if(exists$all_res_freq{$qpos_mnus2} and $relative_freq > $all_res_freq{$query_pos}/$all_res_freq{$qpos_mnus2}){
						$relative_freq=$all_res_freq{$query_pos}/$all_res_freq{$qpos_mnus2};
						}
					if(exists$all_res_freq{$qpos_mnus3} and $relative_freq > $all_res_freq{$query_pos}/$all_res_freq{$qpos_mnus3}){
						$relative_freq=$all_res_freq{$query_pos}/$all_res_freq{$qpos_mnus3};
						}
					if(exists$all_res_freq{$qpos_mnus4} and $relative_freq > $all_res_freq{$query_pos}/$all_res_freq{$qpos_mnus4}){
						$relative_freq=$all_res_freq{$query_pos}/$all_res_freq{$qpos_mnus4};
					}
			###	al final de este arbol decisional, $relative_freq contiene el valor mas bajo del ratio entre 
					if($relative_freq > $clustered_residue_freq && $all_res_freq{$query_pos} > $res_cut_off){	
						$all_site_res{$query_pos}="";
						$numbering_filtered_residues++;
						$FINAL_SQUARE_SCORE_COMBO+=$global_SQUARE_best_score{$query_pos};
						if(exists$summary{"resnum"}[$autoincr]){
							$summary{"resnum"}[$autoincr]="$summary{resnum}[$autoincr] $query_pos";
							$summary{"resname"}[$autoincr]="$summary{resname}[$autoincr] $_";
							my $frequenza=sprintf "%.2f", $all_res_freq{$query_pos};
							$summary{"resresume"}[$autoincr].="$_($query_pos); ";
							$summary{"resfreq"}[$autoincr].="$_($query_pos)=$frequenza; ";
							$summary{"SQUARE"}[$autoincr].=" $query_pos($all_scorez{$query_pos})";
							push (@{$pred_sites_list{$autoincr}},$query_pos);
							$all_bind_res{$autoincr}="$all_bind_res{$autoincr} $query_pos";
							$all_bind_res_ids{$autoincr}="$all_bind_res_ids{$autoincr} $ids";
							}
						else{	$summary{"resnum"}[$autoincr]=$query_pos;
							$summary{"resname"}[$autoincr]=$_;
							my $frequenza=sprintf "%.2f", $all_res_freq{$query_pos};
							$summary{"resresume"}[$autoincr]="$_($query_pos); ";
							$summary{"resfreq"}[$autoincr]="$_($query_pos)=$frequenza; ";
							$summary{"SQUARE"}[$autoincr]="$query_pos($all_scorez{$query_pos})";
							push (@{$pred_sites_list{$autoincr}},$query_pos);
							$all_bind_res{$autoincr}=$query_pos;
							$all_bind_res_ids{$autoincr}=$ids;
						}
					}
				}
			}
		}
	}
	else{next;}
	if ($numbering_filtered_residues==0){$FINAL_SQUARE_SCORE_COMBO=0;}
	else{
		$FINAL_SQUARE_SCORE_COMBO=$FINAL_SQUARE_SCORE_COMBO/$numbering_filtered_residues;	###     TRASH
	}												###     TRASH
	push(@{$site_score{$autoincr}},$numbering_filtered_residues);					###     TRASH
	${$site_score{$autoincr}}[1]=$FINAL_SQUARE_SCORE_COMBO;						###     TRASH
}

my @order=sort{$b<=>$a}(keys%summary_order);
my $ord=0;
my $joinSites=join(" ",values%summary_order);
my @joinSites=split(/ /,$joinSites);
my $scalar_sites=scalar@joinSites;

###################################### NEW SITE' SCORE #############################################

## Hemos guardado informacion sobre cada cluster of sites en el hash %site_score con clave el/los ID(s) del clustered site.
## En concreto se trata del mejor Score de SQUARE entre todos los sites clusterizados y su respectivo coverage, mas la
## mejor posicion en el hash de alineamientos psiout (no necesariamente esta informacion tiene que llegar del mismo alineamiento
## de donde se han sacado los otros dos parametros. Se normalizan (a parte del coverage) y se hace una media aritmetica, luego convertida en 
## porcentaje. Este score teoricamente va de 0 a 3, pero si un site llega hasta aqui, no puede llegar a ser 0.

my %whoisthere;
my @ordered_sites=sort{$b<=>$a}@num_of_sites;
my %score_list;
foreach my $god_hand(@order){
        my @spl=split(/ /,$summary_order{$god_hand});
        foreach my $z (@spl){
		my $new_coverage;
		if (${$site_score{$z}}[3]>${$site_score{$z}}[2]){$new_coverage=1;}
		else {$new_coverage=${$site_score{$z}}[3]/${$site_score{$z}}[2];}
		my $R_Ali=rali($summary{numOfSites}[$z],$ordered_sites[0]);
		#my $park=$new_coverage+2*((${$site_score{$z}}[1])/6)+((${$site_score{$z}}[0])/100)+$R_Ali;
                $score_list{$z}=sprintf("%.3f",($new_coverage+2*((${$site_score{$z}}[1])/6)+((${$site_score{$z}}[0])/100)+$R_Ali));
		#$score_list{$z}=sprintf("%.3f",$park);
                my $output=sprintf("%.1f",($score_list{$z}/5)*100);
		$summary{reliability}[$z]=$output;					# aqui guardamos el reliability score para el filtro !!
		if ($output >= $cutoff and $OPTION eq "CASP"){$whoisthere{$summary{"nice_try"}[$z]}=3;}
                $output.="% [COV: ".ceil($new_coverage*100)."% SITE: ";
                $output.=floor((${$site_score{$z}}[1])/6*100)."% Ident: ".${$site_score{$z}}[0]."% - Ali: ";
		$output.=ceil(sprintf("%.1f",($R_Ali*100)))."%]";
                $summary{score}[$z]=$output;
        }    
}
my @scoreList_unsorted;
@order=();

## aquí volvemos a ordenar los sites segun su reliabiliy
foreach (keys(%score_list)){push(@scoreList_unsorted,$score_list{$_});}
my @scoreList=sort {$b <=> $a} @scoreList_unsorted;
foreach my $a (@scoreList){
        foreach my $i(keys(%score_list)){
                if ($score_list{$i}==$a){push(@order,"$i ");delete($score_list{$i});}
        }    
}

###################################### NEW SITE' SCORE #### [end] ###################################

######################## ELIMINATING REDUNDANT BINDING SITE #########################################
## este es un bucle para eliminar clustered sites que solapan perfectamente con otro site mas grande
## esto puede pasar si no se han clusterizado al principio y luego se han quitado algunos residuos por
## los filtros. No se eliminan tal cual los sites, se han puesto reglas para dar la prioridad a los
## COGNATE !! (No deberia verificarse esta situacion, pero en el caso de que haya misma longitud entre
## un site y otro, nos quedamos con el site con el score mas alto)

my %shinigami;
foreach my $id1(keys%all_bind_res){
        my @res1=split(/ /,$all_bind_res{$id1});
        my $len1=scalar@res1;
        my $type1=$summary{type}[$id1];
        my $score1= $summary{score}[$id1];
        foreach my$id2(keys%all_bind_res){
                unless($id1 eq $id2){
                        my @res2=split(/ /,$all_bind_res{$id2});
                        my $len2=scalar@res2;
                        my $type2=$summary{type}[$id2];
                        my $score2= $summary{score}[$id2];
                        my $common=0;
                        foreach my$uno(@res1){
                                foreach my$dos(@res2){
                                        if($uno eq $dos){
                                                $common++;
                                        }
                                }
                        }
                        if ($common == $len1 && $common == $len2){
                                if ($type1 eq $type2 && $score1 > $score2){$shinigami{$id2}=4;}
                                elsif ($type1 eq $type2 && $score1 < $score2){$shinigami{$id1}=4;}
                        }
                        else {
                                if($common == $len1 && $type1 eq "NOM"){$shinigami{$id1}=4;}
                                elsif($common == $len2 && $type2 eq "NOM"){$shinigami{$id2}=4;}
                                elsif($common == $len1 && $type1 eq "MET" && $type1 eq $type2){$shinigami{$id1}=4;}
                                elsif($common == $len2 && $type2 eq "MET" && $type1 eq $type2){$shinigami{$id2}=4;}
                                elsif($common == $len1 && $type1 eq "MET_POSS"){$shinigami{$id1}=4;}
                                elsif($common == $len2 && $type2 eq "MET_POSS"){$shinigami{$id2}=4;}
                                elsif($common == $len1 && $type1 eq "NOM_COG" && $type1 eq $type2){$shinigami{$id1}=4;}
                                elsif($common == $len2 && $type2 eq "NOM_COG" && $type1 eq $type2){$shinigami{$id2}=4;}
                        }
                }
        }
}

######################## ELIMINATING REDUNDANT BINDING SITE  #### [end] ##############################


## APPRIS CHANGE [begin] ##
####################################### PRINTING RESULTS ############################################

if (defined $OPTION && $OPTION eq "appris"){
	my %suma_de_todos;
	my %suma_de_csa;
	my $name;
	my $compounder;
	my $position;
	my $OUTPUT;
	$OUTPUT = \*STDOUT  unless(open($OUTPUT,'>',$outfile));
	print $OUTPUT "######\n";
	if ($csa_option ne "ONLY"){
		foreach my $incr(@order){
			my @spl=split(/ /,$incr);
			foreach my $key(@spl){
			#	filtros para APPRIS: 
			#		aqui eliminamos todos los sites de compuestos tageados como NON_COGNATE or POSSIBLE COGNATE
				if ($summary{"nice_try"}[$key] eq "NON_COGNATE" or $summary{"nice_try"}[$key] eq "POSSIBLE COGNATE"){next;}

			#		aqui eliminamos todos los sites de compuestos tageados como COGNATE y sin un corte mínimo
				#if ($summary{"nice_try"}[$key] eq "COGNATE" and (${$site_score{$key}}[2] < 0.55)){next;}
				if ($summary{"nice_try"}[$key] eq "COGNATE" and ($summary{reliability}[$key] < 55)){next;}

			#		aqui eliminamos todos los sites de union a metales que salgan de alineamientos con un coverage inferior a 65%
				#if (${$site_score{$key}}[2] < 0.65 && ($summary{"type"}[$key] eq "MET" or $summary{"type"}[$key] eq "MET_POSS")){next;}
				if ($summary{reliability}[$key] < 65 && ($summary{"type"}[$key] eq "MET" or $summary{"type"}[$key] eq "MET_POSS")){next;}

			#		aqui eliminamos todos los sites con score de fiabilidad por debajo del umbral establecido en $cutoff
				#if ($summary{reliability}[$key]<$cutoff){next;}

				$ord++;
				my $comptmp=$summary{compid}[$key];
				my @comps=split(/\s+/,$comptmp);
				$compounder=$comps[0];
				if ($compounder=~/(\w+)\(.+/){$compounder=$1;}
				if (exists $suma_de_todos{$compounder}){
					my $new="other".$ord."-".$compounder;
					push(@{$suma_de_todos{$new}},$summary{resfreq}[$key],$summary{SQUARE}[$key],$summary{reliability}[$key]);
				}
				else {
					push(@{$suma_de_todos{$compounder}},$summary{resfreq}[$key],$summary{SQUARE}[$key],$summary{reliability}[$key]);
				}
			}
		}
	}
	############# Filtro CSA
	if ($csa_option eq "YES" or $csa_option eq "ONLY"){
		for(my$i=1;$i<$csaincr+1;$i++){
			chomp($summary_csa{resnum}[$i]);
			my @number_composition=split(/ /,$summary_csa{resnum}[$i]);
			foreach (@number_composition){
				$suma_de_csa{$_}=$all_csa{$_};
			}
		}
	}
	############# END 
	my @sequence=split(//,$sequence);
	my %aa_totales;
	if (scalar(keys%suma_de_todos)>0 or scalar(keys%suma_de_csa)>0){
		foreach my $i (keys%suma_de_todos){
			my $flag="NO";
			my $compuesto;
			if ($i=~/other\d+\-(\w+)/){$compuesto=$1;}
			else {$flag="YES";}
			my $site=${$suma_de_todos{$i}}[0];
			my $relia_score=${$suma_de_todos{$i}}[2];
			$site=~s/\s//g;
			chomp($site);
			my @parking=split(/;/,$site);
			my @scorez=split(/ /,${$suma_de_todos{$i}}[1]);
			my %all_scorez;
			foreach (@scorez){
				if ($_=~/(\d+)\((\d)\)/){$all_scorez{$1}=$2;}
			}
			foreach (@parking){
				$_=~s/\s//g;
				my @info=split(/=/,$_);
				if ($info[0]=~/([A-Z])\((\d+)\)/){$name=$1;$position=$2;}
				if (exists $aa_totales{$position}){
					my $scorium;
					if ($flag eq "YES"){$scorium="$i\[$info[1],$all_scorez{$position},$relia_score\]";}
					else {"$compuesto\[$info[1],$all_scorez{$position},$relia_score\]";}
					$aa_totales{$position}[1].= "|".$scorium;
				}
				else {
					my $motif=$sequence[($position-7)].$sequence[($position-6)].$sequence[($position-5)].$sequence[($position-4)];
					my $motif=$motif.$sequence[($position-3)].$sequence[($position-2)].$sequence[($position-1)].$sequence[$position];
					my $motif=$motif.$sequence[($position+1)].$sequence[($position+2)].$sequence[($position+3)];
					my $motif=$motif.$sequence[($position+4)].$sequence[($position+5)];
					push(@{$aa_totales{$position}},$motif);
					my $scorium;
					if ($flag eq "YES"){$scorium="$i\[$info[1],$all_scorez{$position},$relia_score\]";}
					else {$scorium="$compuesto\[$info[1],$all_scorez{$position},$relia_score\]";}
					push(@{$aa_totales{$position}},$scorium);
				}
			}
		}	
		foreach my $posi (keys%suma_de_csa){
			if (exists $aa_totales{$posi}){
		#		if ($suma_de_csa{$posi}>${$aa_totales{$posi}}[3]){${$aa_totales{$posi}}[3]=$suma_de_csa{$posi};}
		#		$aa_totales{$posi}[2].= "|"."Cat_Site_Atl";
				my $scorium="Cat_Site_Atl[1.00,$suma_de_csa{$posi},XXX]";
				$aa_totales{$posi}[1].= "|".$scorium;
			}
			else {
		#		push(@{$aa_totales{$posi}},"1.00");
				my $motif=$sequence[($posi-7)].$sequence[($posi-6)].$sequence[($posi-5)].$sequence[($posi-4)];
				my $motif=$motif.$sequence[($posi-3)].$sequence[($posi-2)].$sequence[($posi-1)].$sequence[$posi];
				my $motif=$motif.$sequence[($posi+1)].$sequence[($posi+2)].$sequence[($posi+3)];
				my $motif=$motif.$sequence[($posi+4)].$sequence[($posi+5)];
				push(@{$aa_totales{$posi}},$motif);
		#		push(@{$aa_totales{$posi}},"Cat_Site_Atl");
		#		push(@{$aa_totales{$posi}},$suma_de_csa{$posi});
				my $scorium="Cat_Site_Atl[1.00,$suma_de_csa{$posi},XXX]";
				push(@{$aa_totales{$posi}},$scorium);
			}
			
		}
		my @results=sort{$a<=>$b}keys%aa_totales;
		my $resumen=undef;
		foreach (@results){
			if (defined $resumen){$resumen=$resumen.",".$_;}
			else {$resumen=$_;}
	#		print $OUTPUT "$_\t$aa_totales{$_}[0]\t$aa_totales{$_}[3]\t$aa_totales{$_}[1]\t$aa_totales{$_}[2]\n"
			print $OUTPUT "$_\t$aa_totales{$_}[0]\t$aa_totales{$_}[1]\n";
		}
		print $OUTPUT ">>>$queryname\t",scalar(keys%aa_totales),"\t$resumen\n";
	}
	else {print $OUTPUT ">>>$queryname\t0 predicted residues\n";}
}


## APPRIS CHANGE [end] ##
else{
##################################### CASP #############################################
#	my $possible;
#	if ($OPTION eq "CASP"){
#		if (exists$whoisthere{"COGNATE"}){
#			$csa_option="NO";
#			$possible="NO";
#			$cognate_option="NO";
#		}
#		elsif(exists$whoisthere{"POSSIBLE_COGNATE"}){
#			$csa_option="YES";
#			$possible="YES";
#			$cognate_option="NO";
#		}
#		elsif(exists$whoisthere{"NON_COGNATE"}){
#			$csa_option="YES";
#			$possible="YES";
#			$cognate_option="YES";  
#		}
#	}
################################### [end] CASP #########################################
	my %resume_compounds;
	my @clustids;
	my @ecgoes;
	if($csaincr>0){@clustids=keys%csa_clust;}
	my $OUTPUT;
	$OUTPUT = \*STDOUT  unless(open($OUTPUT,'>',$outfile));
	my %CASP;
	if ($OPTION eq "CASP"){print $OUTPUT "DESTINATION email:\t$CASP_mail\n\nCABECERA ----\n$cabecera\nend -----\n\nPREDICTION -------\n\n";}
	if ($csa_option eq "YES" or $csa_option eq "ONLY"){
		for(my$i=1;$i<$csaincr+1;$i++){
		##########################################################
			my $ecs;
			my $key_res=$summary_csa{resnum}[$i];
			my @control=split(/ /,$key_res);
			$key_res=join(' ',sort@control);
			my @csiteids=split(/ /,$csa_sites{$key_res});
			my %already_seen_ecs;
			my $out_controller="NO";
			foreach my $csiteid(@csiteids){
				my $clustid=$all_csite_info{$csiteid}; 
				$sth = $dataHandle -> prepare("select EC1,EC2,EC3 from INFOACC where CADID=\"$clustid\"");
				$sth -> execute();
				my @ec = $sth -> fetchrow_array();
				$sth -> finish();
				for(@ec){
					if ($_ eq ''){next;}
					if (exists $already_seen_ecs{$_}){next;}
					my $ec=$_;
					$already_seen_ecs{$ec}=5;
					my @tmp=`grep '$ec ' $cwd/../lib/ec2go`;
					if ($out_controller eq "NO"){$ecs.=join("\t\t\t\t\t",@tmp);$out_controller="YES";}
					else{$ecs=$ecs."\t\t\t\t\t".join("\t\t\t\t\t",@tmp);}
				}
			}
			#########################################################
	        	if ($ecs eq ''){$ecs="CAT\t$i\tno EC nor GO information found in our database;";}
			else{chomp($ecs);}
			my $tmps=join(" ",@clustids);
#		if ($OPTION ne "CASP"){
			print $OUTPUT "
CAT	$i	EC_number:		$ecs
CAT	$i	Evidence:		Literature
CAT	$i	Homologs		$tmps
CAT	$i	Residue_positions:	$summary_csa{resnum}[$i]
CAT	$i	Residue_composition:	$summary_csa{resname}[$i]
CAT	$i	Site_score:		$summary_csa{score}[$i]
";}
#			else{
#				my @park=split(/,/,$summary_csa{resnum}[$i]);
#				foreach (@park){$CASP{"$_"}=3;}
#			}
#		}
	}
	if ($csa_option ne "ONLY"){
		foreach my $incr(@order){
			my @spl=split(/ /,$incr);
			foreach my $key(@spl){
##### aqui estamos excluyendo unos resultados dependiendo de los parametros que el usuario nos ha pasado (CUT-OFF reliability, CSA yes/no/only ...)
				if (exists $shinigami{$key}){next;}
				if ($cognate_option eq "NO" &&  $summary{"nice_try"}[$key] eq "NON_COGNATE"){next;}
#				if ($possible eq "NO" &&  $summary{"nice_try"}[$key] eq "POSSIBLE_COGNATE"){next;}
				if ($summary{reliability}[$key]<$cutoff){next;}
##### end
				$ord++;
				my $comptmp=$summary{compid}[$key];
				my @comps=split(/\s+/,$comptmp);
				my @compgo;
				my @goname;
				for(@comps){
					my $id=$_;
					$id=~s/\(\d+\)//;
					if(exists$cif2go{$id}{go2}){
						push(@compgo,$cif2go{$id}{go2});
						push(@goname,$cif2go{$id}{name});
						}
				}
				my $compgos=join(" ",@compgo);
				my $goname=join(", ",@goname);
#				if ($OPTION ne "CASP"){
					print $OUTPUT "
SITE	$ord	Compound_name:			$summary{compname}[$key]
SITE	$ord	Compound_type:			$summary{nice_try}[$key]
SITE	$ord	Compound_id:			$summary{compid}[$key]
SITE	$ord	Compound_GO:			$compgos
SITE	$ord	GO_name:			$goname
SITE	$ord	Residue_positions:		$summary{resnum}[$key]
SITE	$ord	Residue_composition:		$summary{resname}[$key]
SITE	$ord	Per-residue Probab. score:	$summary{resfreq}[$key]
SITE	$ord	Reliability:			$summary{score}[$key]
SITE	$ord	Number_of_homologs:		$summary{numOfSites}[$key]
";
#				}
#				else {
#					my @park=split(/ /,$summary{resnum}[$key]);
#					foreach (@park){$CASP{$_}=3;}
#					if ($summary{"nice_try"}[$key] eq "POSSIBLE_COGNATE"){
#						$resume_compounds{"analog of ".$summary{compname}[$key]}=3;
#					}
#					elsif ($summary{"nice_try"}[$key] eq "NON_COGNATE"){
#						$resume_compounds{"firestar can't predict a biological ligand for this site"}=3;
#					}
#					else {
#						$resume_compounds{$summary{compname}[$key]}=3;
#					}
#				}
			}
		}
	}
#	if ($OPTION ne "CASP"){
		if ($csaincr==0 && scalar@order==0 or ($csa_option eq "NO" && scalar@order==0)){
			print $OUTPUT "
firestar did not detect ligand binding sites for your query";
		}
		elsif ( $csa_option eq "ONLY" && $csaincr==0){
			print $OUTPUT "
firestar did not detect CSA annotation for your query";
		}
		elsif (($csaincr==0 or $csa_option eq "NO") and $ord==0){
			print $OUTPUT "
firestar did not detect ligand binding sites using your filters for your query";
		}
		close($OUTPUT);
		# `touch $faatmp/$tmpfile.log`;
		my $T;
		# BEGIN: APPRIS -> IMPORTANT
		#open($T,'>',"$faatmp/$tmpfile.log");
		open($T,'>',"$temporal/$tmpfile.log");
		# END: APPRIS -> IMPORTANT
		close($T);
#	}
#	else{
#		print $OUTPUT "This is the target:\n\n";
#		print $OUTPUT "\t>$queryname\n";
#		print $OUTPUT "\t$sequence\n\nAnd this is the prediction:\n\n";
#		print $OUTPUT $cabecera;
#		if (scalar(keys%CASP)>0){
#			my @array = sort {$a <=> $b } keys%CASP;
#			my $prediction=join(',',@array);
#			print $OUTPUT $prediction;
#			@array=(); @array = sort {$a cmp $b } keys%resume_compounds;
#			my $compounds=join(',',@array);
#			my $clausura="\nComment: Possible ligand(s)-> $compounds;\nEND";
#			print $OUTPUT $clausura;
#			close($OUTPUT);
#			my $content=$cabecera.$prediction.$clausura;
#			$sender->MailMsg({subject=>$subject_CASP,msg=>$content});
#		}
#		else{
#			my $clausura="\nComment: firestar did not detect ligand binding sites for this target\nEND";
#			print $OUTPUT $clausura;
#			close($OUTPUT);
		if ($OPTION eq "CASP"){
			my $content="\nfirestar has just finished the analysis for the target $queryname\n";
			$content.="You can check the results at /Users/firedb/Sites/FireDB/tmp/CASP_results/$queryname.txt\n";
			$content.="Remember that an email hasn't been sent to CASP yet.\n";
			# BEGIN: APPRIS -> IMPORTANT -> COMMENTED TEMPORALLY
			#$sender->MailMsg({subject=>$subject_CASP,msg=>$content});
			# END: APPRIS -> IMPORTANT -> COMMENTED TEMPORALLY			
		}
#		}
#		sendEmail($CASP_mail,$remitente,$subject_CASP,$content);
#	}
}

# BEGIN: APPRIS -> IMPORTANT
#if (-e "$faatmp/$tmpfile.mn"){
#	unlink ("$faatmp/$tmpfile.sn");
#	unlink ("$faatmp/$tmpfile.pn");
#	unlink ("$faatmp/$tmpfile.mn");
#	unlink ("$faatmp/$tmpfile.aux");
##	unlink ("$faatmp/$tmpfile.log");
#}
if (-e "$temporal/$tmpfile.mn"){
	unlink ("$temporal/$tmpfile.sn");
	unlink ("$temporal/$tmpfile.pn");
	unlink ("$temporal/$tmpfile.mn");
	unlink ("$temporal/$tmpfile.aux");
	unlink ("$temporal/$tmpfile.log");
}
# END: APPRIS -> IMPORTANT 

$dataHandle -> disconnect();

#close(LOG);
#close(TRASH);
END;


###################################################################################
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

sub parse_psiblast{
# BEGIN: APPRIS
#if ($OPTION ne "appris"){
#	open(PSI,"$cwd/../tmp/faatmp/$tmpfile\_$evalue.psi") or print "no pude abrir $tmpfile\_$evalue.psi ../tmp/faatmp/$tmpfile.psi";
#}
#else{open(PSI,"$cwd/../tmp/faatmp/$tmpfile.psi") or print "no pude abrir $tmpfile.psi ../tmp/faatmp/$tmpfile.psi";}
if ($OPTION ne "appris") {
	open(PSI,"$temporal/$tmpfile\_$evalue.psi") or print "no pude abrir $temporal/$tmpfile\_$evalue.psi";
}
else {
	open(PSI,"$temporal/$tmpfile.psi") or print "no pude abrir $temporal/$tmpfile.psi";
}
# END: APPRIS

my @psifile=<PSI>;close PSI;
my @evalue=grep{$_=~/^ Score/}@psifile;
my @psiout=grep{$_=~/^>/ or $_=~/^ Identities/ or $_=~/^Query:/ or $_=~/^Sbjct:/}@psifile;
for(@psiout){
	$_=~s/^>/>\n/;
	}
my $allpsi=join("",@psiout);
@psiout=split(/>/,$allpsi);
my $keyId=0;
for(my$i=0;$i<100;$i++){
	my $ln=$psiout[$i];
	$ln=~s/^\n//;	$ln=~s/\n$//;
	my @ev=split(/,/,$evalue[$i]);
	my $expect=$ev[1];	$expect=~s/\s+//g;	$expect=~s/Expect=//;
	my @ALN=split(/\n/,$ln);
	my $template=shift@ALN;
	if($#ALN >1){
		my @ID=();
		for(my $i=0;$i<$#ALN+1;$i++){
			if($ALN[$i]=~/Identities/){
				push(@ID,$i);
				}
			}
		my @SINGLE=();
		my $queryStart;	
		my $tempStart;
		my $queryEnd;
		my $tempEnd;
		for(my $j=0;$j<$#ID+1;$j++){
			if(exists$ID[$j+1]){@SINGLE=@ALN[$ID[$j]..$ID[$j+1]-1];}
			else{@SINGLE=@ALN[$ID[$j]..$#ALN];}
			my $identities=shift@SINGLE;
			my @temp=grep{$_=~/^Sbjct/}@SINGLE;
			my @query=grep{$_=~/^Query/}@SINGLE;
			my @SEtemp=split(/\s+/,$temp[0]);
			my @SEquery=split(/\s+/,$query[0]);
			$queryStart=$SEquery[1];		# Residuo de comienzo queryet
			$tempStart=$SEtemp[1];			# Residuo de comienzo template
			@SEquery=split(/\s+/,$query[$#query]);
			@SEtemp=split(/\s+/,$temp[$#temp]);
			$queryEnd=$SEquery[3];			# Residuo final queryet
			$tempEnd=$SEtemp[3];			# Residuo final template
			my $tempSeq="";
			my $querySeq="";
			for(@query){
				my @spl=split(/\s+/,$_);
				$querySeq=$querySeq.$spl[2];
				}
			for(@temp){
				my @spl=split(/\s+/,$_);
				$tempSeq=$tempSeq.$spl[2];
				}
			$keyId++;
			$psiout{$keyId}[0]=$tmpfile;
			$psiout{$keyId}[1]=$querySeq;
			$psiout{$keyId}[2]=$template;
			$psiout{$keyId}[3]=$tempSeq;
			$psiout{$keyId}[4]=$queryStart;
			$psiout{$keyId}[5]=$queryEnd;
			$psiout{$keyId}[6]=$tempStart;
			$psiout{$keyId}[7]=$tempEnd;
			$psiout{$keyId}[8]=$identities;
			$psiout{$keyId}[9]=$expect;
			$psiout{$keyId}[10]='PSI';
			}
		}
	}
}

sub parse_hhsearch{
        my $tmpfile=$_[0];
        my $queryname=$_[1];
	my $querySeq;
        my $template;
        my $tempSeq;
        my $identities;
        my $expect;
        my $flag1="OFF";
        my @coords_query;
        my @coords_templ;
        my $keyId=scalar(keys%psiout)+1;
        
        # BEGIN: APPRIS
        #open(HHR,"$cwd/../tmp/faatmp/$tmpfile.hhr") or print "no pude abrir $tmpfile.hhr en $cwd/../tmp/faatmp/";
        open(HHR,"$temporal/$tmpfile.hhr") or print "no pude abrir $temporal/$tmpfile.hhr";
        # END: APPRIS
                
        while (defined(my $line=<HHR>)){
                if ($line=~/>.+/){
                        if (defined $template){
                                $psiout{$keyId}[0]=$queryname;
                                $psiout{$keyId}[1]=$querySeq;
                                $psiout{$keyId}[2]=$template;
                                $psiout{$keyId}[3]=$tempSeq;
                                $psiout{$keyId}[4]=$coords_query[0];
                                $psiout{$keyId}[5]=$coords_query[$#coords_query];
                                $psiout{$keyId}[6]=$coords_templ[0];
                                $psiout{$keyId}[7]=$coords_templ[$#coords_templ];
                                $psiout{$keyId}[8]=$identities;
                                $psiout{$keyId}[9]=$expect;
				$psiout{$keyId}[10]='HHS';
                                $keyId++;
                                $flag1="OFF";
                                $querySeq="";$tempSeq="";@coords_templ=();@coords_query=();
                                $template=$line;$template=~s/>//;chomp($template);
                        }
                        else {$template=$line;$template=~s/>//;chomp($template);}
                }
		elsif($line=~/^Probab/){
                        if ($flag1 eq "ON"){
                                $psiout{$keyId}[0]=$queryname;          #V
                                $psiout{$keyId}[1]=$querySeq;
                                $psiout{$keyId}[2]=$template;
                                $psiout{$keyId}[3]=$tempSeq;
                                $psiout{$keyId}[4]=$coords_query[0];
                                $psiout{$keyId}[5]=$coords_query[$#coords_query];
                                $psiout{$keyId}[6]=$coords_templ[0];
                                $psiout{$keyId}[7]=$coords_templ[$#coords_templ];
                                $psiout{$keyId}[8]=$identities;         #V
                                $psiout{$keyId}[9]=$expect;             #V
				$psiout{$keyId}[10]='HHS';
                                $keyId++;
                        }
                        $flag1="ON";
                        my @parking=split(/\s+/,$line);
                        $expect=$parking[1];$expect=~s/E-value=//;
			my $Probab=$parking[0];
                        $Probab=~s/Probab=//;
                        if ($Probab<5){close(HHR);last;}
                        $identities=join(", ",$parking[4],$parking[0]);
                }
                	elsif($line=~/^Q $queryname/ || $line=~/^Q Query/ || ($line=~/^Q/ && $line!~/ss_pred|ss_conf|Consensus|Query/)){
		        my @parking=split(/\s+/,$line);
                        push(@coords_query,$parking[2],$parking[4]);
                        $querySeq.=$parking[3];
                }
                elsif(defined $template && $line=~/^T $template/){
                        my @parking=split(/\s+/,$line);
                        push(@coords_templ,$parking[2],$parking[4]);
                        $tempSeq.=$parking[3];
                }
                else{next;}
        }
	close(HHR);
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
sub run_psiblast{
	my $sequence=$_[1];
	my $evalue=$_[2];
	my $psifile="$tmpfile\_$evalue";

	# BEGIN: APPRIS
	#open(TMP,">$faatmp/$tmpfile.faa") or print "Error $tmpfile.faa no se abre<br>";
	#print TMP ">Query\n$sequence";
	#close TMP;
	open(TMP,">$temporal/$tmpfile.faa") or print "Error $tmpfile.faa no se abre<br>";
	print TMP ">Query\n$sequence";
	close TMP;	
	# END: APPRIS

	my $flag;
	if ($OPTION ne "appris"){
		$flag="NO";
		# BEGIN: APPRIS
		#open (PSIDONE,"$faatmp/FAA_LOG.txt");
		open (PSIDONE,"$temporal/FAA_LOG.txt");
		# END: APPRIS		
        	while (<PSIDONE>){
			chomp($_);
			my @check=split(/\t/,$_);
			my $already_run=$check[0];
			# BEGIN: APPRIS
			#if ($sequence eq $check[1] && -e "$faatmp/$already_run.hhr"){
			if ($sequence eq $check[1] && -e "$temporal/$already_run.hhr"){
			# END: APPRIS			
				$flag="YES";
				my $chkfile=$already_run;
				my $parking=`ls $cwd/../tmp/faatmp/$chkfile*.psi`;
				chomp($parking);
				$parking=~s/\.psi$//;
				my @spl=split(/_/,$parking);
				my $psidoneval=$spl[$#spl];
				if($evalue == $psidoneval){                     ## en este caso copiamos los ficheros de analisis anteriores para acelerar
					# BEGIN: APPRIS
					#`cp $faatmp/$chkfile.chk $faatmp/$tmpfile.chk`;
        	        #               `cp $faatmp/$chkfile.hhr $faatmp/$tmpfile.hhr`;                 ##### PAOLO #####
                	#               `cp $faatmp/$chkfile.mtx $faatmp/$tmpfile.mtx`;                 ##### PAOLO #####
					#$chkfile="$chkfile\_$psidoneval";
					#`cp $faatmp/$chkfile.psi $faatmp/$psifile.psi`;
					#return $psifile,$tmpfile;
					`cp $temporal/$chkfile.chk $temporal/$tmpfile.chk`;
					`cp $temporal/$chkfile.hhr $temporal/$tmpfile.hhr`;
					`cp $temporal/$chkfile.mtx $temporal/$tmpfile.mtx`;
					$chkfile="$chkfile\_$psidoneval";
					`cp $temporal/$chkfile.psi $temporal/$psifile.psi`;
					return $psifile,$tmpfile;
					# END: APPRIS
				}
				else{
					# BEGIN: APPRIS
					#`cp $faatmp/$chkfile.chk $faatmp/$tmpfile.chk`;         ## recuperamos el chk y corremos PSI-BLAST contra FireDB
					#`cp $faatmp/$chkfile.hhr $faatmp/$tmpfile.hhr`;         ##### PAOLO #####
					`cp $temporal/$chkfile.chk $temporal/$tmpfile.chk`;
					`cp $temporal/$chkfile.hhr $temporal/$tmpfile.hhr`;						
					# END: APPRIS
					RUN_BABY_RUN($evalue,"PSI");
					return $psifile,$tmpfile;
				}
				last;
			}
		}
		close(PSIDONE);
	}
	else{	#esta parte se ha modificado para APPRIS !!! corre HHsearch solo si la prot tiene menos de 251 aa y corre en AHSOKA !!
		$flag="NO";
		# BEGIN: APPRIS
		#open (PSIDONE,"$faatmp/FAA_LOG.txt");
		open (PSIDONE,"$temporal/FAA_LOG.txt");
		# END: APPRIS		
		while (<PSIDONE>){
			chomp($_);
			my @check=split(/\t/,$_);
			my $already_run=$check[0];
			# BEGIN: APPRIS
			#if ($sequence eq $check[1] && length($sequence)<=250 && -e "$faatmp/$already_run.hhr"){
			if ($sequence eq $check[1] && length($sequence)<=250 && -e "$temporal/$already_run.hhr"){
			# END: APPRIS
				$flag="YES";
				$tmpfile=$already_run;	#### OJO !!! esta parte es superimportante porque cambiamos el nombre temporal !!!!!!!
			}
			# BEGIN: APPRIS
			#elsif($sequence eq $check[1] && length($sequence)>250 && -e "$faatmp/$already_run.psi"){
			elsif($sequence eq $check[1] && length($sequence)>250 && -e "$temporal/$already_run.psi"){
			# END: APPRIS
				$flag="YES";
				$tmpfile=$already_run;	#### OJO !!! esta parte es superimportante porque cambiamos el nombre temporal !!!!!!!
			}
		}
		close(PSIDONE);
	}
        if ($flag eq "NO" && $OPTION ne "appris"){
	        	# BEGIN: APPRIS
                #open (PSIDONE,">>$cwd/../tmp/faatmp/FAA_LOG.txt");
                open (PSIDONE,"$temporal/FAA_LOG.txt");
                # END: APPRIS
                print PSIDONE "$tmpfile\t$sequence\n";
                close(PSIDONE);
#		CATON($evalue,$psifile);			
		RUN_BABY_RUN($evalue,"ALL");			### subrutina para correr HHS y PSI en Caton
                return $psifile,$tmpfile;
        }
	elsif ($flag eq "NO" && $OPTION eq "appris"){
				# BEGIN: APPRIS
				#open (PSIDONE,">>$cwd/../tmp/faatmp/FAA_LOG.txt");
				open (PSIDONE,"$temporal/FAA_LOG.txt");
				# END: APPRIS
                print PSIDONE "$tmpfile\t$sequence\n";
                close(PSIDONE);
                # BEGIN: APPRIS
                #AHSOKA($evalue,$tmpfile,length($sequence));	### subrutina para correr HHS y PSI en Ahsoka (distinta de la de firePredSum.pl)
                #AHSOKA($evalue,"ALL");	### Now, we don't take into account the length of sequence for APPRIS
                WORKSTATION($evalue,"ALL");	### Now, we don't take into account the length of sequence for APPRIS
                # END: APPRIS
                return $psifile,$tmpfile;	
	}
}

sub psi_output_generator{
my %result=();
my %sortids=();
my %clustids=();
my $runtype=$_[1];
my $target_file=$_[2];
my $target_chain=$_[3];
my @seq_to_msa;			# almacena las cadenas para hacer msa, solo cuando el navegador no es firefox
my $queryseqfile=$_[0];
my @name=split(/\//,$queryseqfile);
my @splname=split(/_/,$name[$#name]);
my $off=$#splname-1;
my $faaname=join("_",@splname);
my %msa_list;

my %afm_temp_score;

foreach my $key (keys%psiout){
	my $query=$psiout{$key}[0];		# nombre del fichero temporal
	my $query_out=$query;
	my $query_aln=$psiout{$key}[1];		# secuencia alineada de la query
	my $template=$psiout{$key}[2];		# nombre del template encontrado
	my $temp_aln=$psiout{$key}[3];		# secuencia alineada del template
	my $q_start=$psiout{$key}[4];		# coordenada absoluta del primer aminoacido de la query en este alineamiento
	my $q_end=$psiout{$key}[5];		# coordenada absoluta del ultimo aminoacido de la query en este alineamiento
	my $t_start=$psiout{$key}[6];		# coordenada absoluta del primer aminoacido del TEMPLATE en este alineamiento
	my $t_end=$psiout{$key}[7];		# coordenada absoluta del ultimo aminoacido del TEMPLATE en este alineamiento
	my $length_alignment=$q_end-$q_start+1;
	my $identities=$psiout{$key}[8];	# identities del alineamiento (y probabilidad en el caso de HHsearch)
#########################################################################################################################################
#						ONLY FOR FIRESTAR EVALUATION								#
#########################################################################################################################################
	my $identit;
	if ($identities=~/\d+\/\d+\s+\((\d+)%\)/ && $psiout{$key}[10] eq "PSI"){$identit=$1;}
	elsif ($identities=~/Identities=(\d+)%,/ && $psiout{$key}[10] eq "HHS"){$identit=$1;}
#	if ($identit>65){next;}
#########################################################################################################################################
	my $expect=$psiout{$key}[9];		# Evalue proporcionado por el programa
	my @afmout=`$afmpath $query_aln $temp_aln $template`;		# aqui se lanza el programa another_fire_mess_web; 
	for(@afmout){chomp $_;$_=~s/\s+//g;}
	$afmout[2]=~s/@/6/g;
	my @afm_query=split(//,$afmout[1]);	# este array contiene los a.a. de la query, alineados 		e.g.	KLIEQAKKWGHPAIAVTDHA
	my @afm_tempt=split(//,$afmout[0]);	# este array contiene los a.a. del template, alineados 		e.g.	EMVLKAIELDFDEYSIVEHA
	my @afm_score=split(//,$afmout[2]);	# este array contiene los score de SQUARE por cada posicion 	e.g.	221----1-------12343
	my $afm_mean=0;
	for(my $i=0;$i<$#afm_score+1;$i++){
		if($afm_score[$i] eq "-"){$afm_score[$i]=0;}		# e.g.	221----1 => 22100001
		elsif($afm_score[$i] eq "@"){$afm_score[$i]=6;}		# e.g.	@34----2 => 63400002
		$afm_mean=$afm_mean+$afm_score[$i];	## al final del bucle en $afm_mean no tenemos una media sino una suma de todos los scores.
	}
# aqui estamos evaluando el alineamiento: si hay por lo menos un a.a. con un score de SQUARE de 2, entra
	if($afm_mean >1){
		$afm_mean = $afm_mean/($#afm_score+1); # aqui si que hacemos la media aritmetica
		my %afm_temp_score;
		my %afm_temp_aa;
		my %afm_targ_aa;
		my %afm_targ_num;
		my $t_count=0;
		my $q_count=0;
		
		for(my $i=0;$i<$#afm_tempt+1;$i++){ # en este bucle genera 4 hashes en los cuales se guardan informacion relativa:
			if($afm_tempt[$i] =~ /[A-Z]/){
				my $t_pos=$t_start+$t_count;
				$t_count++;
				if($afm_query[$i] =~ /[A-Z]/){
					my $q_pos=$q_start+$q_count;
					$q_count++;
					$afm_targ_num{$t_pos}=$q_pos;		# CLAVE: pos. absoluta templ VALOR: pos. absoluta query
					$afm_temp_aa{$t_pos}=$afm_tempt[$i];	# CLAVE: pos. absoluta templ VALOR: a.a. correspondiente template
					$afm_targ_aa{$t_pos}=$afm_query[$i];	# CLAVE: pos. absoluta templ VALOR: a.a. correspondiente query
					$afm_temp_score{$t_pos}=$afm_score[$i];	# CLAVE: pos. absoluta templ VALOR: SQUARE score de la posicion
				}
			}
			elsif($afm_tempt[$i] !~ /[A-Z]/ and $afm_query[$i] =~ /[A-Z]/){
				$q_count++;
			}
		}
		
		$sth = $dataHandle -> prepare("select CSITEID,NUMCONRES,CONRES,CLUSTID,CSITESUM,SITETYPE,EVIDENCY,COMPIDS,NUMSEQS,SITEIDS,LIGTYPE,SCORE from CSITE35 where CLUSTID=\"$template\" and (SCORE=2 or SCORE=3)");
		$sth -> execute();
		
		while(my @csite_info = $sth -> fetchrow_array()){
			my $csiteid="$csite_info[0]\_$key";		# codigo del SITE (numero secuencial) con la CLAVE de %psiout
			my $ligtype=$csite_info[10];			# tipo de ligando (METAL/NO METAL/Catalytic SA)
			my $compids=$csite_info[7];			# IDs del(los) compuesto(s)
			my $clustid=$csite_info[3];			# Nombre del cluster
			my $evidence=$csite_info[6];			# Evidencia del site (e.g. LITerature/PSIblast)
			my @numconres=split(/ /,$csite_info[1]);	# Posicion absoluta en el cluster de los binding residues
			my @conres=split(//,$csite_info[2]);		# codigo de una letra de todos los a.a. del binding site
			my $firedb_score=$csite_info[12];		# score del site de FireDB
			my $mean_score=0;
			
			my @good_res=();
			my @fucking_good_res=();		# residues with score higher than 5
			my @xxx_good_res=();			# residues with score higher than 4
		################################## INITIAL COGNATE TAGGING OF THE PREDICTIONS #########################
			my $cognate_count=0;
			my $non_cognate_count=0;
			my $TAG_COGNATE;
			my @PARKED_LIGANDS=split(/ /,$compids);
			if (scalar@PARKED_LIGANDS>0){
				foreach my $xy (@PARKED_LIGANDS){
					if ($xy=~/(\w+)\((\d+)\)/){
						if (exists $cognate{$1} or $poss_cognate{$1}){$cognate_count=$cognate_count+$2;}	## OLD VERSION
			#			if (exists $cognate{$1}){$cognate_count=$cognate_count+$2;}		## CHANGE CASP 10
			#			elsif($poss_cognate{$1}){next;}						## CHANGE CASP 10
						else {$non_cognate_count=$non_cognate_count+$2;}
					}
				}
				if ($cognate_count>=$non_cognate_count && $cognate_count!=0){$TAG_COGNATE="YES";}	## OLD VERSION
		#		if ($cognate_count>0){$TAG_COGNATE="YES";}						## CHANGE CASP 10
				else{$TAG_COGNATE="NON";}
			}

		################################## FIREDB STORED OCCURRENCE ##########################
			my $occurre;
			if($ligtype ne "CSA"){
				my $sth1=$dataHandle -> prepare("select OCCURRENCE from CCTEVAL_35 where CSITEID=\"$csiteid\"");
				$sth1 -> execute();
				$occurre= $sth1 -> fetchrow_array();
			}
		#####################################################################################
			if($ligtype eq "MET" && $compids!~/ZN\(\d+\)/ && $occurre > 30){
				for(my $i=0;$i<$#numconres+1;$i++){	
					my $t_pos=$numconres[$i];
					if(exists$afm_targ_num{$t_pos} and $afm_temp_score{$t_pos} > $residue_score_metal){
		# primer caso: aqui se comprueba en el caso de que el ligando sea un metal y no sea Zinc
                # se mira en el alineamiento si las posiciones anotadas en FireDB tienen un score superior a un umbral previamente establecido
                # (en este caso $residue_score_metal=3) y se guardan en el array @good_res
						push(@good_res,$t_pos);
						if($afm_temp_score{$t_pos} >= 6){push(@fucking_good_res,$t_pos)}; 
				# este es una ulterior comprobacion para mirar los residuos muy conservados 
					}
				$mean_score=$mean_score+$afm_temp_score{$t_pos}; # aqui calculamos un score de SQUARE medio para todo el site !!
				}
			}
			elsif($ligtype eq "MET" && $compids=~/ZN\(\d+\)/ && $occurre > 30){		
                                for(my $i=0;$i<$#numconres+1;$i++){
                                        my $t_pos=$numconres[$i];
                                        if(exists$afm_targ_num{$t_pos} and $afm_temp_score{$t_pos} >=5){ 
		# filtro para el ZINC: se tiene en cuenta de un residuo solo si tiene un score de 5 o 6
                                                push(@good_res,$t_pos);
                                                push(@fucking_good_res,$t_pos);
                                        }
					elsif(exists$afm_targ_num{$t_pos} and $afm_temp_score{$t_pos} >=4){
						push(@good_res,$t_pos);
					}
                                	$mean_score=$mean_score+$afm_temp_score{$t_pos};
                                }
                        }
			elsif($ligtype eq "NOM"){
				for(my $i=0;$i<$#numconres+1;$i++){
					my $t_pos=$numconres[$i];
					if(exists$afm_targ_num{$t_pos} and $afm_temp_score{$t_pos} > $residue_score_no_metal){
		# segundo caso: aqui se comprueba en el caso de que el ligando sea no meta
		# el umbral en este caso $residue_score_no_metal=2
						$mean_score=$mean_score+$afm_temp_score{$t_pos};
						push(@good_res,$t_pos);
						if($afm_temp_score{$t_pos} >= 4){push(@xxx_good_res,$t_pos)};
				# este es una ulterior comprobacion para mirar los residuos muy conservados menos restrictiva que la de los metales
					}
				}
			}
		#	elsif($ligtype eq "CSA" and $evidence eq "lit"){
		#		for(my $i=0;$i<$#numconres+1;$i++){
		#			my $t_pos=$numconres[$i];
		#			if(exists$afm_targ_num{$t_pos} and $afm_temp_score{$t_pos} > $residue_score_csa){
		#		#		$mean_score=$mean_score+$afm_temp_score{$t_pos};
		#				push(@good_res,$t_pos);
		#			}
		#			$mean_score=$mean_score+$afm_temp_score{$t_pos};
		#		}
		#	}
			elsif($ligtype eq "CSA"){
				@good_res=();
				my %good_res;
				for(my $i=0;$i<$#numconres+1;$i++){
					my $t_pos=$numconres[$i];
					if(exists$afm_targ_num{$t_pos} and $afm_temp_score{$t_pos} >= 6){
						$good_res{$t_pos}=5;
					}
					if(exists$afm_targ_num{$t_pos} and $afm_temp_score{$t_pos} >= $residue_score_csa){
						if ( $afm_temp_aa{$t_pos} eq $afm_targ_aa{$t_pos}){
							$good_res{$t_pos}=5;
						}
					}
					$mean_score=$mean_score+$afm_temp_score{$t_pos};
				}
				@good_res=keys%good_res;
			}
			if(scalar@good_res>0 && ($ligtype eq "MET" || $ligtype eq "CSA")){
				$mean_score=$mean_score/($#numconres+1);			######## CHANGE ########
				# aqui calculamos la media dividiendo la suma de los scores del los a.a. del site en el alineamiento por el numero
				# tot. de los residuos anotados del site
			}
			elsif (scalar@good_res>0 && $ligtype eq "NOM"){				######## CHANGE #########
				$mean_score=$mean_score/($#good_res+1);
				# aqui calculamos la media dividiedo por el numero de a.a. por encima del umbral, ya que son sites mas variables
			}
			else{$mean_score=0;}
			if($ligtype eq "MET" and ($mean_score/$afm_mean >= $absolute_afm_score_metal)){
				# primer filtro para un metal: la media del score de SQUARE del site dividida por la del alineamiento tiene que ser 
				# mayor de un umbral previamente establecido ($absolute_afm_score_metal=1)
				if($#good_res+1 > 1 && (($#good_res+1)*100/($#numconres+1)) > $cutPercentage_metal && (scalar@fucking_good_res>0 or scalar@good_res>2)){
				# segundo filtro: mas de un residuo conservado, el total de residuos conservados tiene que ser superior de un porcentaje
				# ($cutPercentage_metal=49.99) y tiene que haber por lo menos 1 residuo muy conservado (score SQUARE>=6)
					if ($compids=~/CA\(\d+\)/){
						my %controller;
						for(my $i=0;$i<$#good_res+1;$i++){
							$controller{$afm_targ_aa{$good_res[$i]}}++;
						}
				#		my $suma=$controller{"D"}+$controller{"N"}+$controller{"E"};
						my $suma=$controller{"D"}+$controller{"N"}+$controller{"E"}+$controller{"S"};
				#		if (scalar@good_res==2 && $suma<2){next;}
						if (scalar@good_res>=2 && $suma<2){next;}
				#		elsif (scalar@good_res>2 && $suma<3){next;}
					}
					if ($compids=~/MG\(\d+\)/){
						my %controller;
						for(my $i=0;$i<$#good_res+1;$i++){
							$controller{$afm_targ_aa{$good_res[$i]}}++;
						}
						my $suma=$controller{"D"}+$controller{"E"};
						if ($controller{"D"}<1 && $controller{"E"}<1){next;}
						elsif (scalar@good_res<3){next;}
					}
					if ($compids=~/ZN\(\d+\)/ && scalar@fucking_good_res<2 && scalar@good_res<3){next;}
				# en el caso del ZN los residuos muy conservados tienen que ser minimo 2
					else {
						$all_csite_info{$csiteid}="$compids";
						if ($length_alignment>$longest_alignment_cutoff){$longest_alignment_cutoff=$length_alignment;}
						for(my $i=0;$i<$#good_res+1;$i++){
							my $t_pos=$good_res[$i];
							my $target_resnum=$afm_targ_num{$t_pos};
							${$global_SQUARE_MEAN{$csiteid}}{$target_resnum}=$afm_temp_score{$t_pos};
							$all_csite_score{$csiteid}=$mean_score/$afm_mean; 
				# aqui guardamos el score del site en un hash con CLAVE el ID del site
				# (media de los scores de los aa del site/media de los scores de todos los aa del alineamiento)
							$all_csite_mean{$csiteid}=$mean_score; 
				# guardamos en otro hash con CLAVE ID del site el VALOR media de los scores de los aa del site
							$all_csite_coverage{$csiteid}=scalar@numconres;				###     TRASH
							$all_csite_aa{$target_resnum}=$afm_targ_aa{$t_pos};
				# guardamos en otro hash con CLAVE las posiciones absolutas de los aa en la query y VALOR el aa (codigo una letra)
							if(exists$all_met_res{$csiteid}){
								$all_met_res{$csiteid}="$all_met_res{$csiteid} $afm_targ_num{$t_pos}";
				# en este hash con CLAVE ID del site se almacena la pos. absoluta en la query de los aa que han pasado el filtro
							}
							else{$all_met_res{$csiteid}=$afm_targ_num{$t_pos};}
							# BEGIN: for APPRIS report
							if(exists $score_app{$csiteid}) {
								$score_app{$csiteid}="$score_app{$csiteid} $target_resnum($afm_temp_score{$t_pos})";
							}
							else {
								$score_app{$csiteid}="$target_resnum($afm_temp_score{$t_pos})";
							}    
                                                	# END: for APPRIS report
						}
					}
				}
			}
 			elsif($ligtype eq "NOM" and ($mean_score/$afm_mean > $absolute_afm_score_no_metal)){
				# primer filtro para un no_metal igual al anterior: el umbral aqui es $absolute_afm_score_no_metal=1
				if($#xxx_good_res+1 > 4 && (($#xxx_good_res+1)*100/($#numconres+1)) > $cutPercentage){
				# segundo filtro: mas de 4 residuos conservados (los sites son mas grandes), $cutPercentage_metal=24.99
					$all_csite_info{$csiteid}="$compids";
					if ($length_alignment>$longest_alignment_cutoff){$longest_alignment_cutoff=$length_alignment;}
					for(my $i=0;$i<$#good_res+1;$i++){
						my $t_pos=$good_res[$i];
						my $target_resnum=$afm_targ_num{$t_pos};
						${$global_SQUARE_MEAN{$csiteid}}{$target_resnum}=$afm_temp_score{$t_pos};
						$all_csite_score{$csiteid}=$mean_score/$afm_mean;
						$all_csite_mean{$csiteid}=$mean_score;
						$all_csite_coverage{$csiteid}=scalar@numconres;
						$all_csite_aa{$target_resnum}=$afm_targ_aa{$t_pos};
						$all_csite_TAG{$csiteid}=$TAG_COGNATE; 
						if ($TAG_COGNATE eq "YES"){
							if(exists$all_nom_res{$csiteid}){
								$all_nom_res{$csiteid}="$all_nom_res{$csiteid} $afm_targ_num{$t_pos}";
					# si no existe la clave, se crea !! Cuidado que el hash es distinto que el de $ligtype MET
							}
							else{$all_nom_res{$csiteid}=$afm_targ_num{$t_pos};}
						}
						elsif ($TAG_COGNATE eq "NON"){
					# hemos introducido una separacion previa de cognate y non_cognate
							if(exists$all_nom_nocog_res{$csiteid}){
								$all_nom_nocog_res{$csiteid}="$all_nom_nocog_res{$csiteid} $afm_targ_num{$t_pos}";
							}
							else{$all_nom_nocog_res{$csiteid}=$afm_targ_num{$t_pos};}
						}
						# BEGIN: for APPRIS report
						if (exists $score_app{$csiteid}){
							$score_app{$csiteid}="$score_app{$csiteid} $target_resnum($afm_temp_score{$t_pos})";
						}
						else {
							$score_app{$csiteid}="$target_resnum($afm_temp_score{$t_pos})";
						}
						# END: for APPRIS report
					}
				}
			}
			elsif($ligtype eq "CSA"){
                                my $ali_cov=($q_end-$q_start+1)/length$sequence;
                                my $pass="NO";
                                if (length$sequence <= 120 && $ali_cov >= 0.5){$pass="YES";}
                                elsif (length$sequence > 120 && $length_alignment>70){$pass="YES";}
                        #       if(($#good_res+1)==($#numconres+1) and $mean_score>4)
                                if((($#good_res+1)*100/($#numconres+1)) > $cutPercentage_csa && $mean_score>4){
                                # primer filtro para un CSA: todos los residuos anotados tienen que tener un score superior a 3
                                # y la media del score de SQUARE para el site tiene que ser > 4
                                        $all_csite_info{$csiteid}="$clustid";
                                        for(my $i=0;$i<$#good_res+1;$i++){
                                                my $t_pos=$good_res[$i];
                                                my $target_resnum=$afm_targ_num{$t_pos};
                                                $all_csa_aa{$target_resnum}=$afm_targ_aa{$t_pos};
                                                if(exists$all_csa_res{$csiteid}){
                                                        $all_csa_res{$csiteid}.=" $afm_targ_num{$t_pos}";
                                # same old story !!
                                                        $all_csa_score{$csiteid}.=$afm_temp_score{$t_pos};
                                                        $csa_res_freq{$afm_targ_num{$t_pos}}++;         #####   NEW
                                                }
                                                else{   $all_csa_res{$csiteid}=$afm_targ_num{$t_pos};
                                                        $all_csa_score{$csiteid}=$afm_temp_score{$t_pos};
                                                        $csa_res_freq{$afm_targ_num{$t_pos}}++;         #####   NEW
                                                }
                                                if ($identit >= 30 && $pass eq "YES"){
                                                        if ($identit >= 60 && exists $all_csa_res_60{$csiteid}){
                                                                $all_csa_res_60{$csiteid}.=" $afm_targ_num{$t_pos}";
                                                                $all_csa_score_60{$csiteid}.=$afm_temp_score{$t_pos};
                                                                $csa_res_freq_60{$afm_targ_num{$t_pos}}++;
                                                        }
                                                        elsif($identit >= 60){
                                                                $all_csa_res_60{$csiteid}=$afm_targ_num{$t_pos};
                                                                $all_csa_score_60{$csiteid}=$afm_temp_score{$t_pos};
                                                                $csa_res_freq_60{$afm_targ_num{$t_pos}}++;
                                                        }
                                                        if(exists $all_csa_res_30{$csiteid}){
                                                                $all_csa_res_30{$csiteid}.=" $afm_targ_num{$t_pos}";
                                                                $all_csa_score_30{$csiteid}.=$afm_temp_score{$t_pos};
                                                                $csa_res_freq_30{$afm_targ_num{$t_pos}}++;
                                                        }
                                                        else{
                                                                $all_csa_res_30{$csiteid}=$afm_targ_num{$t_pos};
                                                                $all_csa_score_30{$csiteid}=$afm_temp_score{$t_pos};
                                                                $csa_res_freq_30{$afm_targ_num{$t_pos}}++;
                                                        }
                                                }
                                        }
                                }
                        }
		}
		$sth -> finish();
	}
}
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
sub residue_clustering{
	my $first_cutoff=$clust_cut1;
	# cut-off pre-establecido; de momento vale 0.6
	my $scnd_cutoff=$clust_cut2;
	# el otro cut-off; de momento vale igual que el anterior, 0.6 
	my %finalClstr=();
	foreach my $id1(keys%all_csite_res){ 		### a este hash se asigna un valor distinto cada llamada; CLAVE: CSITE_ID; VALOR: pos absol AA;
		$finalClstr{$id1}=$id1;				### %finalClstr es el hash final donde se guardan por cada clust-id los otros
		my @res1=split(/ /,$all_csite_res{$id1});	### IDs de los clusters con los que comparten el 60% de los aa !!
		my $len1=scalar@res1;
		my @aparca=split(/_/,$id1);
		my $CSITE1=$aparca[0];
		$sth = $dataHandle -> prepare("select LIGTYPE from CSITE35 where CSITEID=\"$CSITE1\" and (SCORE=2 or SCORE=3)");
		$sth -> execute();
		my @info = $sth -> fetchrow_array();
		my $ligand_type1=$info[0];
		foreach my $id2(keys%all_csite_res){	### aqui empieza una comparacion uno contra todos de los sites
			unless($id1 eq $id2){		
				my @res2=split(/ /,$all_csite_res{$id2});
				my $len2=scalar@res2;
				my $common=0;
				foreach my $uno(@res1){
					foreach my$dos(@res2){
						if($uno eq $dos){ # si la posicion de un aminoacido del primer site es igual a la de otro se aumenta
							$common++;	### esta variable.
							last;
						}
					}
				}
				@aparca=();
				@aparca=split(/_/,$id2);
				my $CSITE2=$aparca[0];
				$sth = $dataHandle -> prepare("select LIGTYPE from CSITE35 where CSITEID=\"$CSITE2\" and (SCORE=2 or SCORE=3)");
				$sth -> execute();
				my @info = $sth -> fetchrow_array();
				my $ligand_type2=$info[0];
				if ($ligand_type1 eq $ligand_type2 && $ligand_type1 eq "NOM"){
					if($common >= $len1 * $first_cutoff or $common >= $len2 * $scnd_cutoff){ 
													## si el numero de los aa en comun es superior
						if(exists$finalClstr{$id1}){				## al 60% de la longitud de ambos sites, se
							$finalClstr{$id1}="$finalClstr{$id1} $id2";	## ponen juntos
						}
						else{   $finalClstr{$id1}=$id2;}
					}
				}
				else {
					if($common >= $len1 * $first_cutoff and $common >= $len2 * $scnd_cutoff){ 
													## si el numero de los aa en comun es superior
						if(exists$finalClstr{$id1}){				## al 60% de la longitud de ambos sites, se
							$finalClstr{$id1}="$finalClstr{$id1} $id2";	## ponen juntos
							}
						else{	$finalClstr{$id1}=$id2;}
					}
				}
			}
		}
	}
	my @cbind=id_clustering(values%finalClstr);
	return @cbind;
}


sub id_clustering{

my @global=@_;
my $start;
my $end;
do{	my %uniq_id=();
	$start=scalar@global;
	for(@global){
		my @spl=split(/ /,$_);
		my $join=join(" ",@spl);
		for my$id(@spl){
			if(exists$uniq_id{$id}){$uniq_id{$id}="$uniq_id{$id} $join";}
			else{$uniq_id{$id}=$join;}
			}
		}
	@global=();
	for(values%uniq_id){
		my @spl = split(/ /,$_);
		my @sort = uniqsort(@spl);
		my $sort = join(" ",@sort);
		push(@global,$sort);
		}
	@global=uniqsort(@global);
	$end=scalar@global;
	}until ($start==$end);
return @global;
}

#==============================================================================


sub ecfill{
my $ret;
my@spl=split(/\./,$_[0]);
if(scalar@spl==1){$ret="$_[0].0.0.0"}
elsif(scalar@spl==2){$ret="$_[0].0.0"}
elsif(scalar@spl==3){$ret="$_[0].0"}
else{$ret=$_[0]}
return $ret;
}

sub readlib{

open(EC2GO,"$cwd/../lib/ec2go");
do{	my $line=readline(EC2GO);
	if($line=~/^EC/){
		my @spl=split(/\s+/,$line);
		my $ec=$spl[0];
		$ec=ecfill($ec);
		my $go=$spl[$#spl];
		$go=~s/GO://;
#		print "$ec	$go\n";
		$ec2go{$ec}=$go;
		}
	}until eof;
close EC2GO;

open(CIF2GO,"$cwd/../lib/cif2go");
do{	my $line=readline(CIF2GO);
	if($line!~/^#/){
		chomp $line;
		my @spl=split(/\t/,$line);
		my $cif=$spl[0];
		$cif2go{$cif}{go1}=$spl[1];
		$cif2go{$cif}{go2}=$spl[2];
		$cif2go{$cif}{name}=$spl[3];
		}
	}until eof;
close CIF2GO;
	open(COGNATE,"$cwd/../lib/cognate.lst");					########## CHANGE #############
	do{     my $line=readline(COGNATE);
		chomp($line);
		$cognate{$line}=5;
	}until eof;
	close COGNATE;
	open(POSS_COGNATE,"$cwd/../lib/poss_cognate.lst");                                        ########## CHANGE #############
	do{     my $line=readline(POSS_COGNATE);
		chomp($line);
		$poss_cognate{$line}=5;
	}until eof; 
        close POSS_COGNATE;
#	%poss_cognate=("SO4"=>"5","NA"=>"5","K"=>"5","BR"=>"5","CL"=>"5");
	open(METALS,"$cwd/../lib/metal.lst");                                        ########## CHANGE #############
	do{     my $line=readline(METALS);
		chomp($line);
		$metals{$line}=5;
	}until eof;
	close METALS;


}

# BEGIN: APPRIS
#sub AHSOKA{
#        my $evalue=$_[0];
#        my $psifile=$_[1];
#	my $length_seq=$_[2];
#        my $home_ahsoka="/Volumes/RAID/Homes/firedb";
#        my $dir="$home_ahsoka/Analysis";
#	my $hhblits_DB="/Volumes/RAID/Homes/firedb/DB/hhblits_$release_date";
#        my $DB="$home_ahsoka/DB";
#	my $salida;
#	my $faatmp="$cwd/../tmp/faatmp";
#	system("cp $faatmp/$tmpfile.faa $dir/.");
#	if ($length_seq<=250){$salida="CHOP";}
#	else {$salida="CHIP";}
#        open(SH,">$faatmp/ahsoka_psi.$tmpfile.sh");
#        print SH "#!/bin/bash\n# Load Environmental variables for \"ahsoka\" cluster\nsource /etc/bashrc\n";
#        print SH "source /etc/profile\nsource \${HOME}/.bashrc\n#\$ -N firePSI_APPRIS\n";
#	print SH "#\$ -e $dir/LOG/$tmpfile.stderr\n#\$ -o $dir/LOG/$tmpfile.stdout\n#\$ -cwd\n";
#        print SH "#\$ -q inb";
#        print SH "\n\nperl $dir/Perl/$tmpfile.psi.pl";
#        close(SH);
#        open(SH2,">$faatmp/ahsoka_hhs.$tmpfile.sh");
#        print SH2 "#!/bin/bash\n# Load Environmental variables for \"ahsoka\" cluster\nsource /etc/bashrc\n";
#        print SH2 "source /etc/profile\nsource \${HOME}/.bashrc\n#\$ -N fireHHS_APPRIS\n";
#	print SH2 "#\$ -e $dir/LOG/$tmpfile.stderr\n#\$ -o $dir/LOG/$tmpfile.stdout\n";
#        print SH2 "#\$ -cwd\n#\$ -m e\n#\$ -q inb";
#        print SH2 "\n\nperl $dir/Perl/$tmpfile.hhs.pl";
#        close(SH2);
#        open (PERL1,">$faatmp/$tmpfile.psi.pl");
#        print PERL1 "#!/usr/bin/perl\n\nuse strict;\nmy \$tmpfile=\"$tmpfile\";\nmy \$dir=\"$dir\";\nmy \$DB=\"$DB\";\nmy \$evalue=\"$evalue\";\n";
#        print PERL1 "my \$release_date=\"$release_date\";\nmy \$nrdb=\"$nrdb\";\nmy \$psifile=\"$psifile\";\nmy \$output=\"$salida\";\n";
#        print PERL1 "`blastpgp -C \$dir/\$tmpfile.chk -d \$DB/\$nrdb -e0.01 -F F -h0.01 -j3 -b0 -v50 -a14 -i \$dir/\$tmpfile.faa`;\n";
#        print PERL1 "`blastpgp -R \$dir/\$tmpfile.chk -a14 -d \$DB/fdbTptDB_\$release_date -F F -e\$evalue -v0 -i \$dir/\$tmpfile.faa -o \$dir/\$psifile.psi`;\n";
#	print PERL1 "if (\$output eq 'CHIP'){\n\t`touch \$dir/\$tmpfile.tmpa`;\n\tsleep(11);\n\t`rm \$dir/\$tmpfile* \$dir/Perl/\$tmpfile*.pl`;\n}\n";
#	print PERL1
#        close PERL1;
#        open (PERL2,">$faatmp/$tmpfile.hhs.pl");
#        print PERL2 "#!/usr/bin/perl\n\nuse strict;\n";
#        print PERL2 "my \$tmpfile=\"$tmpfile\";\nmy \$dir=\"$dir\";\n";
#	print PERL2 "my \$DB=\"$DB\";\nmy \$evalue=\"$evalue\";\nmy \$HHblits_path=\"$home_ahsoka/Programs/hhblits/bin\";\n";
#        print PERL2 "my \$release_date=\"$release_date\";\n";
##	print PERL2 "`\$HHsearch_path/buildali.pl -n 6 -cpu 14 \$dir/\$tmpfile.faa`;\n";
##	print PERL2 "`hhmake -i \$dir/\$tmpfile.a3m`;\n";
##	print PERL2 "`hhsearch -cpu 14 -cal -i \$dir/\$tmpfile.hhm -d \$DB/cal.hhm`;\n";
##	print PERL2 "`hhsearch -cpu 14 -i \$dir/\$tmpfile.hhm -d \$DB/pdb97_\$release_date.hhm -cov 20 -p 5`;\n";
#	print PERL2 "`\$HHblits_path/hhblits -cpu 10 -d $hhblits_DB -i \$dir/\$tmpfile.faa -e \$evalue`;\n";
#	print PERL2 "my \$control=\"FALSE\";\nwhile (\$control eq \"FALSE\"){\n";
#	print PERL2 "\tif (-e \"\$dir/\$tmpfile.psi\"){`touch \$dir/\$tmpfile.tmpa`;\$control=\"TRUE\";}\n";
#	print PERL2 "\telse {sleep(4);}\n}\n";
#        print PERL2 "sleep(11);\n";
#        print PERL2 "`rm \$dir/\$tmpfile* \$dir/Perl/\$tmpfile*.pl`;\n";
#        close PERL2;
#	if ($length_seq<=250){
#		system ("cp $faatmp/$tmpfile.*.pl $dir/Perl");
#		system ("cp $faatmp/ahsoka_*.$tmpfile.sh $dir/QSUB_files/");
#		system ("qsub $dir/QSUB_files/ahsoka_hhs.$tmpfile.sh");
#		system ("qsub $dir/QSUB_files/ahsoka_psi.$tmpfile.sh");
#	}
#	else {
#		system ("cp $faatmp/$tmpfile.psi.pl $dir/Perl");
#		system ("cp $faatmp/ahsoka_psi.$tmpfile.sh $dir/QSUB_files/");
#		system ("qsub $dir/QSUB_files/ahsoka_psi.$tmpfile.sh");
#	}
#        my $control="FALSE";
#        while ($control eq "FALSE"){
#                sleep(5);
#                if (-e "$dir/$tmpfile.tmpa"){$control="TRUE";}
#        }
#	system ("cp -rp $dir/$tmpfile* $faatmp/.");
#        unlink "$faatmp/$tmpfile.tmpa";
#        unlink "$faatmp/$tmpfile.hhs.pl";
#        unlink "$faatmp/$tmpfile.psi.pl";
#        unlink "$faatmp/ahsoka_psi.$tmpfile.sh";
#        unlink "$faatmp/ahsoka_hhs.$tmpfile.sh";
#}
sub AHSOKA{
	my $evalue=$_[0];
	my $option=$_[1];
	my $server=$server;
	my $cp1=CP1->new();
	my $process_id=substr($tmpfile,6,9);
	#my $process_id=$tmpfile;
	my $command='"source \${HOME}/.bashrc;';
	my $dir=$variables->val('CLUSTER_PATHS','root');
	my $user="inb";
	my $header="# Load Environmental variables for \"ahsoka\" cluster";
	$header.="\nsource \${HOME}/.bashrc\n";
	my $queue=$variables->val('CLUSTER_PATHS','ahsoka_queue');
	my $template=$cwd.'/'.'appris_template.pl';
	
print STDERR "\nCOMAND: $command\n";
print STDERR "\nDIR: $dir\n";
print STDERR "\nHEADER: $header\n";
print STDERR "\nQUEUE: $queue\n";
print STDERR "\nSSHCopy:$server: $temporal/$tmpfile.faa => $dir\n";
	$cp1->CPCopy(
		source=>"$temporal/$tmpfile.faa",
		destination=>"$dir/",
	);
print STDERR "\nDONE\n";
print STDERR "SSHCopy2:$server: $conf_file => $dir/Perl/$server\_CONFIG_fire_var.ini\n";
	$cp1->CPCopy(
		source=>$conf_file,
		destination=>"$dir/Perl/$server\_CONFIG_fire_var.ini",
	);
print STDERR "\nDONE\n";
	if ($option eq "ALL"){
print STDERR "SSHCopy3:$server: $template => $dir/Perl/$tmpfile.main.pl\n";		
		$cp1->CPCopy(
			source=>$template,
			destination=>"$dir/Perl/$tmpfile.main.pl",
		);
print STDERR "\nDONE\n";
	}

	open(SH2,">$temporal/$tmpfile.main.sh");
	print SH2 "#!/bin/bash\n$header#\$ -e $dir/LOG/$tmpfile.stderr\n#\$ -o $dir/LOG/$tmpfile.stdout\n";
	print SH2 "#\$ -cwd\n#\$ -q $queue";
	print SH2 "\n\nperl $dir/Perl/$tmpfile.main.pl $tmpfile $evalue $temporal $server $process_id $conf_file";
	close(SH2);
print STDERR "SSHCopy6:$server: $temporal/$tmpfile.main.sh => $dir/QSUB_files\n";	
	$cp1->CPCopy(
			source=>"$temporal/$tmpfile.main.sh",
			destination=>"$dir/QSUB_files",
	);
print STDERR "\nDONE\n";
print STDERR "SSHExecute7:$server: m$process_id $dir/QSUB_files/$tmpfile.main.sh\n";	
	$cp1->SSHExecute(
                user=>$user,
                host=>"$server",
                name=>"m$process_id",
                file_cmd=>"$dir/QSUB_files/$tmpfile.main.sh",
        );
print STDERR "\nDONE\n";

	my $control="FALSE";
	while ($control eq "FALSE") {
		sleep(5);
		if (-e "$temporal/$tmpfile.hhr" && -e "$temporal/$tmpfile.mtx"){$control="TRUE";}
print STDERR "\n$temporal/$tmpfile.hhr:$control\n";
	}
	unlink "$temporal/$tmpfile.main.sh";
#print STDERR "\nMAIN_PROCESS_CONTROLLER_1($command,$option,$process_id,FIRST)\n";
#	MAIN_PROCESS_CONTROLLER($command,$option,$process_id,"FIRST");
#print STDERR "\nDONE\n";
#	my $control="FALSE";
#	my $contador;
#	while ($control eq "FALSE"){
#		$contador++;
#		if (-e "$temporal/$tmpfile.hhr" && -e "$temporal/$tmpfile.mtx"){$control="TRUE";}
#		elsif(($contador % 5)==0){
#			my $flag="RED";
#			while($flag eq "RED"){
#				my @qstat=`$command qstat -u '*'" | grep m$process_id`;
#				if (scalar@qstat==0){
#print STDERR "SSHExecute8:$server: m$process_id $dir/QSUB_files/$tmpfile.main.sh\n";
#					$cp1->SSHExecute(
#						user=>$user,
#						host=>"$server",
#						name=>"m$process_id",
#						file_cmd=>"$dir/QSUB_files/$tmpfile.main.sh",
#					);
#print STDERR "\nDONE\n";
#				}
#				else{
#print STDERR "\nMAIN_PROCESS_CONTROLLER_2($command,$option,$process_id,SECOND)\n";
#					MAIN_PROCESS_CONTROLLER($command,$option,$process_id,"SECOND");
#					$flag="GREEN";
#print STDERR "\nDONE\n";
#				}
#			}
#		}
#		sleep(6);
#	}
#	unlink "$temporal/$tmpfile.main.sh";

}
# END: APPRIS


# BEGIN: APPRIS
sub WORKSTATION{
	my $evalue=$_[0];
	my $option=$_[1];
	my $server=$server;
	my $cp1=CP1->new();
	my $process_id=substr($tmpfile,6,9);
	#my $process_id=$tmpfile;
	my $command='"source \${HOME}/.bashrc;';
	my $dir=$variables->val('CLUSTER_PATHS','root');
	my $user="inb";
	my $header="# Load Environmental variables for \"ahsoka\" cluster";
	$header.="\nsource \${HOME}/.bashrc\n";
	my $queue=$variables->val('CLUSTER_PATHS','ahsoka_queue');
	my $template=$cwd.'/'.'appris_ws_template.pl';
	
	$cp1->CPCopy(
		source=>"$temporal/$tmpfile.faa",
		destination=>"$dir/",
	);
	$cp1->CPCopy(
		source=>$conf_file,
		destination=>"$dir/Perl/$server\_CONFIG_fire_var.ini",
	);	
	$cp1->CPCopy(
		source=>$template,
		destination=>"$dir/Perl/$tmpfile.main.pl",
	);
	eval {
		my $cmd = "perl $dir/Perl/$tmpfile.main.pl $tmpfile $evalue $temporal $server $conf_file";
		system($cmd);
	};

}
# END: APPRIS


sub RUN_BABY_RUN{
        my $evalue=$_[0];
	my $option=$_[1];
        my $cluster_name;
        my $ssh=Ubio::Utils::SSH->new();
        my $dir;my $header;
	my $process_id=substr($tmpfile,3,9);
	############################################### EVALUANDO EL ESTADO DE CARGA DE LOS CLUSTERS #################################
#	my $load_ahsoka=CHUCKER("ahsoka");
#	if ($load_ahsoka ==100){$cluster_name="caton";}
#	elsif ($load_ahsoka > 80){
#		my $load_caton=CHUCKER("caton");
#		if ($load_caton > 90){$cluster_name="ahsoka";}
#		else {$cluster_name="caton";}
#	}
#	else {$cluster_name="ahsoka";}
	##############################################################################################################################
	$cluster_name="caton";                  #################### 10 Apr 2012 Ahsoka esta muerto !! quitar cuando haya vuelto
        my $command;
	my $queue;
        if ($cluster_name eq "caton"){$command='ssh firedb@caton "source .bashrc;';}
        elsif ($cluster_name eq "ahsoka"){$command='ssh firedb@ahsoka "source .bashrc;';}
        if ($cluster_name eq "ahsoka"){
                $dir="/home/firedb/Analysis";
                $header="# Load Environmental variables for \"ahsoka\" cluster";
                $header.="\nsource \${HOME}/.bashrc\n";
		$queue=$variables->val('CLUSTER_PATHS','ahsoka_queue');
        }
        elsif($cluster_name eq "caton"){
		$dir="/home/firedb/Analysis";
		$header="source /home/firedb/.bashrc\n";
		$queue=$variables->val('CLUSTER_PATHS','caton_queue');
	}
        $ssh->SSHCopy(
                source=>"$temporal/$tmpfile.faa",
                destination=>$dir,
                host=>"$cluster_name",
        );
	$ssh->SSHCopy(
		source=>"$home/CONFIG_fire_var.ini",
		destination=>"$dir/Perl/$server\_CONFIG_fire_var.ini",
		host=>"$cluster_name",
	);
	if ($option eq "ALL"){
		$ssh->SSHCopy(
			source=>"$cwd/$cluster_name\_template.pl",
			destination=>"$dir/Perl/$tmpfile.main.pl",
			host=>"$cluster_name",
		);
	}
	if ($option eq "PSI"){
		$ssh->SSHCopy(
			source=>"$cwd/PSI_$cluster_name\_template.pl",
			destination=>"$dir/Perl/$tmpfile.main.pl",
			host=>"$cluster_name",
		);
		$ssh->SSHCopy(
			source=>"$temporal/$tmpfile.chk",
			destination=>$dir,
			host=>"$cluster_name",
		);
	}
        open(SH2,">$temporal/$tmpfile.main.sh");
        print SH2 "#!/bin/bash\n$header#\$ -e $dir/LOG/$tmpfile.stderr\n#\$ -o $dir/LOG/$tmpfile.stdout\n";
        print SH2 "#\$ -cwd\n#\$ -M pmaietta\@cnio.es\n#\$ -m e\n#\$ -q $queue";
        print SH2 "\n\nperl $dir/Perl/$tmpfile.main.pl $tmpfile $evalue $temporal $server";
        close(SH2);
        $ssh->SSHCopy(
                source=>"$temporal/$tmpfile.main.sh",
                destination=>"$dir/QSUB_files",
                host=>"$cluster_name",
        );
        $ssh->SSHExecute(
                user=>"firedb",
                host=>"$cluster_name",
                name=>"m$process_id",
                file_cmd=>"$dir/QSUB_files/$tmpfile.main.sh",
        );
	sleep(5);
	MAIN_PROCESS_CONTROLLER($command,$option,$process_id,"FIRST");
        my $control="FALSE";
	my $contador;
        while ($control eq "FALSE"){
		$contador++;
                if (-e "$temporal/$tmpfile.hhr" && -e "$temporal/$tmpfile.mtx"){$control="TRUE";}
		elsif(($contador % 5)==0){
			my $flag="RED";
			while($flag eq "RED"){
				my @qstat=`$command qstat -u '*'" | grep m$process_id`;
				if (scalar@qstat==0){
					$ssh->SSHExecute(
						user=>"firedb",
						host=>"$cluster_name",
						name=>"m$process_id",
						file_cmd=>"$dir/QSUB_files/$tmpfile.main.sh",
					);
					$flag="GREEN";
				}
				else{
					MAIN_PROCESS_CONTROLLER($command,$option,$process_id,"SECOND");
					$flag="GREEN";
				}
			}
		}
                sleep(6);
        }
        # BEGIN: APPRIS
        #unlink "$faatmp/$tmpfile.main.sh";
        unlink "$temporal/$tmpfile.main.sh";
        # END: APPRIS 
}

sub CHUCKER {
	my $clust_name=$_[0];
	my $overture;
	my $total_CPU;
	my @runtime_nodes;
	if ($clust_name eq "caton"){
		$overture='ssh firedb@caton "source .bashrc; qstat -f"';
		my $cola=$variables->val('CLUSTER_PATHS','caton_queue');
		@runtime_nodes=`$overture | grep '$cola'`;
		$total_CPU=4;
	}
	elsif ($clust_name eq "ahsoka"){
		$overture='ssh firedb@ahsoka "source .bashrc; qstat -f"';
		my $cola=$variables->val('CLUSTER_PATHS','ahsoka_queue');
		@runtime_nodes=`$overture | grep '$cola'`;
		$total_CPU=16;
	}
#	my @runtime_nodes=`$overture | grep 'runtime\\|normal'`;
	my $total_ocCPU;
	my $contador;
	if (scalar@runtime_nodes==0){return(100);}
	foreach (@runtime_nodes){
		my @parking=split(/\s+/,$_);
		$contador++;
		my @nod=split(/\@/,$parking[0]);
		my $run_node=$nod[1];
		my @all_charge=`$overture | grep '$run_node'`;
		foreach my $i (@all_charge){
			@parking=();
			@parking=split(/\s+/,$i);
			my @parking2=split(/\//,$parking[2]);
			$total_ocCPU+=$parking2[1];
		}
	}
	my $charge=($total_ocCPU/($total_CPU*$contador))*100;
	return($charge);
}


sub rali{
        my $number=$_[0];
        my $MAX=$_[1];
        my $b;
        if ($MAX>100){
                my $multiplier=100/$MAX;
                $b=($multiplier*$number)/100;
                #     if ($number>100){$b=1;}
                #     else{$b=$number/100;}
        }
        elsif ($MAX>10){
                $b=$number/$MAX;
                $b=sprintf("%.2f",$b);
        }
        else {
                $b=$number/10;
        }
        return($b);
}

sub MAIN_PROCESS_CONTROLLER {
	my $command=$_[0];
	my $option=$_[1];
	my $identifier=$_[2];
	my $tag=$_[3];
	my $bandera="RED";
	while($bandera eq "RED"){
		my @qstat_main=`$command qstat -u '*'" | grep m$identifier`;
		my @files=`$command ls Analysis/Perl/" | grep $tmpfile`;
		if (scalar@qstat_main == 0 && scalar@files == 0 && $tag eq "SECOND"){$bandera="GREEN";}
		my $number_process=substr($qstat_main[0],0,7);$number_process=~s/\s+//;
		my $string=substr($qstat_main[0],8);
		my @state=split(/\s+/,$string);
		if ($state[3] eq "Eqw"){
			`$command qmod -c $number_process"`;
			sleep(3);
			$bandera="GREEN";
		}
		elsif ($state[3] eq "r" && $tag eq "SECOND"){$bandera="GREEN";}
		elsif ($state[3] eq "r"){
			my @HP_processes=`$command qstat -u '*'" | grep $identifier | grep -v m$identifier`;
			if ($option eq "ALL" && scalar@HP_processes==2 && scalar@files==3){$bandera="GREEN";}
			if ($option eq "PSI" && scalar@HP_processes==1 && scalar@files==2){$bandera="GREEN";}
		}
		else {sleep(3);$bandera="GREEN";}
	}
}


sub CATON{
        my $evalue=$_[0];
        my $psifile=$_[1];
	my $length_seq=$_[2];
        my $home_caton="/home/firedb";
        my $dir="$home_caton/Analysis";
	my $hhblits_DB="/home/firedb/DB/hhblits_$release_date";
        my $DB="$home_caton/DB";
	my $salida;
	my $faatmp="$cwd/../tmp/faatmp";
	system("cp $faatmp/$tmpfile.faa $dir/.");
	if ($length_seq<=250){$salida="CHOP";}
	else {$salida="CHIP";}
        open(SH,">$faatmp/caton_psi.$tmpfile.sh");
	print SH "#!/bin/bash\n";
	print SH "#\$ -e $dir/LOG/$tmpfile.stderr\n#\$ -o $dir/LOG/$tmpfile.stdout\n#\$ -cwd\n";
	print SH "#\$ -q runtime\n#\$ -N APP_fireP\nsource /home/firedb/.bashrc";
	print SH "\n\nperl $dir/Perl/$tmpfile.psi.pl";
	close(SH);
        open(SH2,">$faatmp/caton_hhs.$tmpfile.sh");
	print SH2 "#!/bin/bash\n";
	print SH2 "#\$ -e $dir/LOG/$tmpfile.stderr\n#\$ -o $dir/LOG/$tmpfile.stdout\n";
	print SH2 "#\$ -cwd\n#\$ -q runtime\n#\$ -N APP_fireH\nsource /home/firedb/.bashrc";
	print SH2 "\n\nperl $dir/Perl/$tmpfile.hhb.pl";
	close(SH2);
        open (PERL1,">$faatmp/$tmpfile.psi.pl");
	print PERL1 "#!/usr/bin/perl\n\nuse strict;\nmy \$tmpfile=\"$tmpfile\";\nmy \$dir=\"$dir\";\nmy \$DB=\"$DB\";\nmy \$evalue=\"$evalue\";\n";
	print PERL1 "my \$release_date=\"$release_date\";\nmy \$nrdb=\"$nrdb\";\nmy \$psifile=\"$psifile\";\nmy \$output=\"$salida\";\n";
	print PERL1 "`blastpgp -C \$dir/\$tmpfile.chk -d \$DB/\$nrdb -e0.01 -F F -h0.01 -j3 -b0 -v50 -a4 -i \$dir/\$tmpfile.faa`;\n";
	print PERL1 "`blastpgp -R \$dir/\$tmpfile.chk -a4 -d \$DB/fdbTptDB_\$release_date -F F -e\$evalue -v0 -i \$dir/\$tmpfile.faa -o \$dir/\$psifile.psi    `;\n";
	print PERL1 "if (\$output eq 'CHIP'){\n\t`touch \$dir/\$tmpfile.tmpa`;\n\tsleep(11);\n\t`rm \$dir/\$tmpfile* \$dir/Perl/\$tmpfile*.pl`;\n}\n";
	close PERL1;
        open (PERL2,">$faatmp/$tmpfile.hhb.pl");
	print PERL2 "#!/usr/bin/perl\n\nuse strict;\n";
	print PERL2 "my \$tmpfile=\"$tmpfile\";\nmy \$dir=\"$dir\";\n";
	print PERL2 "my \$DB=\"$DB\";\nmy \$evalue=\"$evalue\";\nmy \$HHblits_path=\"$home_caton/Programs/hhblits/bin\";\n";
	print PERL2 "my \$release_date=\"$release_date\";\n";
	print PERL2 "`\$HHblits_path/hhblits -cpu 4 -d $hhblits_DB -i \$dir/\$tmpfile.faa -e \$evalue`;\n";
	print PERL2 "my \$control=\"FALSE\";\nwhile (\$control eq \"FALSE\"){\n";
	print PERL2 "\tif (-e \"\$dir/\$tmpfile.psi\"){`touch \$dir/\$tmpfile.tmpa`;\$control=\"TRUE\";}\n";
	print PERL2 "\telse {sleep(4);}\n}\n";
	print PERL2 "sleep(11);\n";
	print PERL2 "`rm \$dir/\$tmpfile* \$dir/Perl/\$tmpfile*.pl`;\n";
	close PERL2;
	if ($length_seq<=250){
		system ("cp $faatmp/$tmpfile.*.pl $dir/Perl");
		system ("cp $faatmp/caton_*.$tmpfile.sh $dir/QSUB_files/");
		system ("qsub $dir/QSUB_files/caton_hhs.$tmpfile.sh");
		system ("qsub $dir/QSUB_files/caton_psi.$tmpfile.sh");
	}
	else {
		system ("cp $faatmp/$tmpfile.psi.pl $dir/Perl");
		system ("cp $faatmp/caton_psi.$tmpfile.sh $dir/QSUB_files/");
		system ("qsub $dir/QSUB_files/caton_psi.$tmpfile.sh");
	}
        my $control="FALSE";
        while ($control eq "FALSE"){
                sleep(5);
                if (-e "$dir/$tmpfile.tmpa"){$control="TRUE";}
        }
	system ("cp -rp $dir/$tmpfile* $faatmp/.");
        unlink "$faatmp/$tmpfile.tmpa";
        unlink "$faatmp/$tmpfile.hhs.pl";
        unlink "$faatmp/$tmpfile.psi.pl";
        unlink "$faatmp/caton_psi.$tmpfile.sh";
        unlink "$faatmp/caton_hhs.$tmpfile.sh";
}

sub sendEmail{
	my ($to, $from, $subject, $message) = @_;
	my $sendmail = '/usr/sbin/sendmail';
	open(MAIL, "|$sendmail -oi -t");
		print MAIL "From: $from\n";
		print MAIL "To: $to\n";
		print MAIL "Bcc: pmaietta\@cnio.es\n";
		print MAIL "Subject: $subject\n\n";
		print MAIL "$message\n";
		close(MAIL);
} 
