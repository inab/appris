#!/usr/bin/perl

use strict;

return 1;

END;

sub uniqsort{
my %uniq=();
foreach my$key(@_){
	chomp $key;
	$uniq{$key}="";
	}
my @out=sort{$a<=>$b}(keys(%uniq));
return @out;
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
		foreach my$id(@spl){
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



sub id_clustering2{

my @global=@_;
my $lab=0;
my @tmp;
my %done;
print "***************************\n";
for(my$i=0;$i<$#global+1;$i++){
	unless(exists$done{$i}){
		$done{$i}="";
		print "$global[$i]\n";
		my @spl1=split(/ /,$global[$i]);
		my %uniq=();
		foreach my$key1(@spl1){
			$uniq{$key1}="";
			}
		for(my$j=$i+1;$j<$#global+1;$j++){
			unless(exists$done{$j}){
				my @spl2=split(/ /,$global[$j]);
				$lab=0;
				foreach my$key2(@spl2){
					if(exists$uniq{$key2}){$lab=1}
					}
				if($lab==1){
					$done{$j}="";
					foreach my$key2(@spl2){
						$uniq{$key2}="";
						}
					}
				}
			}
		if(scalar(keys%uniq)>0){
			my $join=join(" ",keys%uniq);
			push(@tmp,$join);
			}
		}
	}

print "###########################\n";
for(@tmp){print "$_\n";}
print "%%%%%%%%%%%%%%%%%%%%%%%%%%%\n";
return @tmp;
}
