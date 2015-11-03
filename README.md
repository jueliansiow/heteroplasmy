# Heteroplasmy

Introduction

This script utilizes existing NGS programs and streamlines their usage





Pre-requisites

Seqtk

$ git clone https://github.com/lh3/seqtk.git
$ cd seqtk
$ make
$ export PATH=$PATH:"$(pwd)"


Fastqutils - requires python. Run "$ sh init.sh" if the make step does not work.

$ git clone git://github.com/ngsutils/ngsutils.git 
$ cd ngsutils 
$ make
$ cd bin
$ export PATH=$PATH:"$(pwd)"


ARC_assembler
