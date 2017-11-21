# makeSampleMap
Perl script for generating a tab-delimited sample map from pyRAD output.

Many of my scripts require input of a tab-delimited sample map.  This format is a plain text file in which each line represents an individual sample.  The sample name is first provided on a line, with a tab separating it from its population designmation.  I use these files to insert population information when converting from pyRAD output files to other formats.  

## Setup:
I have provided an example sample map (sample_map.txt) to show you how I set up the initial input file.  If you would like to use this code for your own files, you will need to make some modifications to the script.
* In line 47 I use a regular expression to match my lab's sample numbering scheme.  This is 1-2 numbers designationg project number, 3-4 letters designating population name, and then 3 numbers designating the individual sample ID for that project/population combo.  You would either have to match your sample names to a similar scheme, or modify the regular expression in this line to match your own scheme.
* I hard-coded the path to my master sample_map.txt file in line 94.  If you do not wish to specify a different master file every time you run the script, then you will need to modify this to specify the path to your own file.

## Usage:
You can view a full list of command line options by executing the script at a command prompt without any additional arguments provided.

This script operates on the structure file output by pyRAD.  To run the script on a file named input.str, do the following:
```
./makemap.pl -s input.str
```
This will generate a file named "map.txt"
