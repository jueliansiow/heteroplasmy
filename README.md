# Heteroplasmy

Introduction

This script utilizes existing NGS programs (Seqtk, Fastqutils, ARC assembler by iBest) and streamlines their usage.



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
