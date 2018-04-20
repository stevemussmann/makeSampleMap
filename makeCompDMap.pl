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
getopts( 'ho:m:c:', \%opts );

# if -h flag is used, or if no command line arguments were specified, kill program and print help
if( $opts{h} ){
  &help;
  die "Exiting program because help flag was used.\n\n";
}

# parse the command line
my( $comp, $out, $master ) = &parsecom( \%opts );

# declare variables
my @complines;
my @popmaplines;
my %hash;
my %indhash;

# put files into array
&filetoarray( $comp, \@complines );
&filetoarray( $master, \@popmaplines );

# remove header
shift( @complines );

foreach my $line( @popmaplines ){
	my @temp = split( /\t/, $line );
	$hash{$temp[0]} = $temp[1];
}

for( my $i=0; $i<@complines; $i++ ){
	my @temp = split( /\t/, $complines[$i]  );
	for( my $j=0; $j<4; $j++ ){
		$indhash{$temp[$j]}++;
	}
}

open( OUT, '>', $out ) or die "Can't open $out: $!\n\n";

foreach my $ind( sort keys %indhash ){
	print OUT $ind, "\t", $hash{$ind}, "\n";
}

close OUT;

#print Dumper( \%indhash );

exit;

#####################################################################################################
############################################ Subroutines ############################################
#####################################################################################################

# subroutine to print help
sub help{
  
  print "\nmakemap.pl is a perl script developed by Steven Michael Mussmann\n\n";
  print "To report bugs send an email to mussmann\@email.uark.edu\n";
  print "When submitting bugs please include all input files, options used for the program, and all error messages that were printed to the screen\n\n";
  print "Program Options:\n";
  print "\t\t[ -h | -o | -m | -s ]\n\n";
  print "\t-h:\tUse this flag to display this help message.\n";
  print "\t\tThe program will die after the help message is displayed.\n\n";
  print "\t-o:\tUse this flag to specify the output file name.\n";
  print "\t\tIf no name is provided, the output file name will be \"map.txt\".\n\n";
  print "\t-m:\tUsed to specify location of master list of samples.\n\n";
  print "\t\tDefault is in same directory as this script.\n\n";
  print "\t-s:\tUse this flag to specify the name of the structure file produced by pyRAD.\n\n";
  
}

#####################################################################################################
# subroutine to parse the command line options

sub parsecom{ 
  
  my( $params ) =  @_;
  my %opts = %$params;
  
  # set default values for command line arguments
  my $comp = $opts{c} || die "No input file specified.\n\n"; #used to specify input file name.  This is the input snps file produced by pyRAD
  my $out = $opts{o} || "$comp.map"  ; #used to specify output file name.  If no name is provided, the file extension ".out" will be appended to the input file name.
  my $master = $opts{m} || "/home/mussmann/local/scripts/perl/makeSampleMap/sample_map.txt"; #used to specify location of the master list of populations

  return( $comp, $out, $master );

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

  # close input file
  close FILE;

}

#####################################################################################################
