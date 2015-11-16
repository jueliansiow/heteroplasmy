# Heteroplasmy

Introduction

This script utilizes existing NGS programs (Seqtk, Fastqutils, ARC assembler by iBest) and streamlines their usage.

--------------------

Pre-requisites

Seqtk and Fastqutils. These can be installed by runnning the shell script 

	$ sh installprereq.sh -i /path/to/install/directory


ARC_assembler - requires Bowtie 2, Spades, biopython and python which would have been installed by Fastqutils.
To install dependencies.

Bowtie 2.
Go to "http://bowtie-bio.sourceforge.net/bowtie2/index.shtml" for specific instructions to install bowtie 2

Spades.
Go to "http://bioinf.spbau.ru/spades/" for specific instructions to install spades.

Biopython - Get biopython via anaconda.
Go to "https://www.continuum.io/downloads" and download the installer.
Run the installer for anaconda
Once anaconda is installed run the following

	$ conda install biopython


To install the ARC_assembler after all dependencies have been installed.

	$ git clone git://github.com/ibest/ARC.git
	$ cd ARC
	$ python setup.py install
	$ cd bin
	$ export PATH=$PATH:"$(pwd)"
	
	
Test to see if the ARC assembler works

	$ cd test_data
	$ ARC


--------------------

Running the scripts


All the scripts below do not check if there is any prior data that has been calculated. It will overwrite and existing files. Please be careful and make sure each run is done in a separate folder. This script is best used to run a bunch of set parameters after the optimal parameters have been investigated.


trimscript.sh
This is a pipeline to trim NGS raw data from a fastq.gz file using seqtk and fastquils. Seqtk and fastquils have to be installed and accessible from any directory prior to running this script. This script will take raw unprocessed reads, remove reads below a PHREAD score of 13 or an equivalent to a 0.05% probability, check to make sure each read is longer than x bp, checking to ensure there are no N's in the reads, followed by a final check to make sure that each read has a pair. Reads with no pairs are removed. These processes are done in the order mentioned. This script outputs three files. One paired merged zipped file where reads have only been trimmed, and another two files (which contain paired reads that have been separated) where the reads have undergone minimum length trimming, N filtering and parity checks. This script will automatically find paired reads with "R1" and ".fastq.gz" in their file names. Be sure that the right files are in the right directory.

./trimscript.sh [-h|--help] [-i|--inputdirectory path/to/directory] [-o|--outputdirectory path/to/directory] [-m|--minreadlgth number]

-h --help= Help message.
-i --inputdirectory= Enter the directory where the files are to be used for analysis.
-o --outputdirectory= Enter the directory where files will be output to after analysis.
-m --minreadlgth= Enter the mininum read length you would like to keep after trimming.


ARCscript.sh
This is a pipeline that takes trimmed NGS reads and subsamples them. Seqtk and fastquils have to be installed and accessible from any directory prior to running this script. This script takes trimmed reads from the trimscript.sh, subsamples it and then uses those subsampled reads in the ARC assembler program. The ARC assembler maps the reads to a provided reference sequences and then assembles the mapped reads to create its own contig. This script will automatically find files with "unmerged" and ".#.fastq.gz" in their file name. # refers to either 1 or 2 usually an indicator of a paired file. This script outputs two files which contain the paired subsampled trimmed raw data and the ARC outputs. Please used the arc config file provided. Feel free to change the settings but not the name of the data files and the arc reference file name in the provided arc config file. Doing so will stop this script from working.

./ARCscript.sh [-i|--inputdirectory path/to/directory] [-o|--outputdirectory path/to/directory] [-n|--numreads number] [-a|--arc_config path/to/file] [-r|--arc_reference path/to/file]

-h --help
-i --inputdirectory= Enter the directory where the files are to be used for analysis.
-o --outputdirectory= Enter the directory where files will be output to after analysis.
-n --numreads = Enter the number of reads that you would like to end up with after sub sampling. The number can be a specific number of reads or a fraction of the reads in decimals.
-a --arc_config= Enter the path to the ARC config file that has been supplied with this script.
-r --arc_reference= Enter the path to the reference file that ARC needs for assembly.



velvetscript.sh
This is a pipeline that takes the subsampled data from the ARCscript.sh and feeds it to velvet. Velvet has to be installed and accessible from any directory prior to running this script. This script will run the dataset through a range of kmer values and the stats of the completed velvet run are then piped to a file called compiled velvet results that will allow you to then choose the results from the range of values calculated. 

-h --help
-o --outputdirectory= Enter the directory where files will be output to after analysis.
-i --inputdirectory= Enter the directory where the files are to be used for analysis.
-l --lowkmer= Enter the lowest kmer value to calculate from. Has to be an odd number
-a --interval= Enter the interval between kmer values which will be calculated. Has to be an even number.
-k --highkmer= Enter the highest kmer value to calculate to. Has to be an odd number.
-g --velvetgoptions= Enter the options that you want velvetg to run. You must include double quotation marks. "[-cov_cutoff value] [-min_contig_lgth value] [-exp_cov value]". Refer to the velvet manual for a full list of options. The clean option has already been added.



wrapperscript.sh
This is a pipeline that takes the triming and subsampling script and runs it on all folders in a directory."

-h --help
-n --num_reads= Enter the number of reads that you would like to end up with after sub sampling. The number can be a specific number of reads or a fraction of the reads in decimals.
-d --outdirectory= Enter the directory where files will be output to after analysis.
-f --folderdirectory= Enter the directory where the files are to be used for analysis.
-a --arc_config= Enter the path to the ARC config file that has been supplied with this script.
-r --arc_reference= Enter the path to the reference file that ARC needs for assembly
-k --min_readlgth= Enter the mininum read length you would like to keep after trimming.
-t --trimscript= Enter the path to where the trimming script lives.
-s --arc_script= Enter the path to where the arc script lives.
-g --velvetg_options= Enter the options that you want velvetg to run. You must include double quotation marks. "[-cov_cutoff number] [-min_contig_lgth number] [-exp_cov number]". Refer to the velvet manual for a full list of options. The clean option has already been added.
-p --velveth_options= Enter range of kmer values that you want to run. "[-l|--lowkmer number] [-k|--highkmer number] [-a|--interval number]"."