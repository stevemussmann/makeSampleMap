#! /usr/bin/perl

use warnings;
use strict;
use Getopt::Std;
use Data::Dumper;

# kill program and print help if no command line arguments were given
if( scalar( @ARGV ) == 0 ){
  &help;
  die "Exiting program because no command line options were used.\n\n";
}

# take command line arguments
my %opts;
getopts( 'ho:m:s:', \%opts );

# if -h flag is used, or if no command line arguments were specified, kill program and print help
if( $opts{h} ){
  &help;
  die "Exiting program because help flag was used.\n\n";
}

# parse the command line
my( $stats, $out, $map ) = &parsecom( \%opts );

my %hash;
my %countshash;
my %totalhash;
my %avgloci;
my %hoa;
my %stdevloci;
my %mapcount;


my @maplines;
my @statslines;
my @counts;

my $nloci = 0;
my $total = 0;
my $ninds = 0;

&filetoarray( $stats, \@statslines );
&filetoarray( $map, \@maplines );

my $bool = 0;
foreach my $line( @statslines ){
	#print $line, "\n";
	if( $line =~ /filtering$/ ){
		my @temp = split( /\s+/, $line );
		#print $temp[0], "\n";
		$nloci = $temp[0];
	}
	if( $line =~ /^taxon/ ){
		$bool = 1;
	}elsif( $line =~ /## nloci/ ){
		$bool = 0;
	}
	if( $bool == 1 ){
		if( $line !~ /^taxon/ ){
			push( @counts, $line );
		}
	}
}

foreach my $line( @maplines ){
	my @temp = split(/\s+/, $line);
	$hash{$temp[0]} = $temp[1];
	$mapcount{$temp[1]}+=1;
}

foreach my $ind( @counts ){
	my @temp = split(/\s+/, $ind);
	$countshash{$hash{$temp[0]}}+=$temp[1];
	push( @{$hoa{$hash{$temp[0]}}}, $temp[1]);
	$totalhash{$hash{$temp[0]}}+=$nloci;
	$total+=$temp[1];
	$ninds+=1;
}

my $missing = 1-($total/($ninds*$nloci));
printf "%.2f\n", 100*$missing;

open( OUT, '>', $out ) or die "can't open $out, $!\n\n";


print OUT "population\tavg_loci\tstdev_loci\tpct_missing\n";

foreach my $pop( sort keys %countshash ){
	$avgloci{$pop} = $countshash{$pop}/$mapcount{$pop};
	my $sum = 0;
	foreach my $thing( @{$hoa{$pop}} ){
		my $num = ($thing-$avgloci{$pop})**2;
		$sum+=$num;
	}
	my $count = scalar(@{$hoa{$pop}});
	$stdevloci{$pop} = sqrt($sum/$count);
	print OUT $pop, "\t";
	printf OUT "%.2f\t", $avgloci{$pop};
	printf OUT "%.2f\t", $stdevloci{$pop};
	printf OUT "%.2f\n", 100*(1-($countshash{$pop}/$totalhash{$pop}));
}

close OUT;

#print Dumper( \@counts );
#print Dumper( \%hash );
#print Dumper( \%countshash );
#print Dumper(\%hoa);


exit;

#####################################################################################################
############################################ Subroutines ############################################
#####################################################################################################

# subroutine to print help
sub help{
  
  print "\nmissingData.pl is a perl script developed by Steven Michael Mussmann\n\n";
  print "To report bugs send an email to mussmann\@email.uark.edu\n";
  print "When submitting bugs please include all input files, options used for the program, and all error messages that were printed to the screen\n\n";
  print "Program Options:\n";
  print "\t\t[ -h | -o | -m | -s ]\n\n";
  print "\t-h:\tUse this flag to display this help message.\n";
  print "\t\tThe program will die after the help message is displayed.\n\n";
  print "\t-o:\tUse this flag to specify the output file name.\n";
  print "\t\tIf no name is provided, the output file name will be \"missingData.txt\".\n\n";
  print "\t-m:\tUsed to specify a population map file.\n\n";
  print "\t\tFormat is sample_name<TAB>pop_name\n\n";
  print "\t-s:\tUse this flag to specify the name of the stats file produced by pyRAD.\n\n";
  
}

#####################################################################################################
# subroutine to parse the command line options

sub parsecom{ 
  
  my( $params ) =  @_;
  my %opts = %$params;
  
  # set default values for command line arguments
  my $stats = $opts{s} || die "No input file specified.\n\n"; #used to specify input file name.  This is the stats by pyRAD
  my $out = $opts{o} || "missingData.txt"  ; #used to specify output file name. 
  my $map = $opts{m} || "map.txt"; #used to specify location of the population map file

  return( $stats, $out, $map );

}

#####################################################################################################
# subroutine to put file into an array

sub filetoarray{

  my( $infile, $array ) = @_;

  
  # open the input file
  open( FILE, $infile ) or die "Can't open $infile: $!\n\n";

  # loop through input file, pushing lines onto array
  while( my $line = <FILE> ){
    chomp( $line );
    next if($line =~ /^\s*$/);
    #print $line, "\n";
    push( @$array, $line );
  }

  close FILE;

}

#####################################################################################################
