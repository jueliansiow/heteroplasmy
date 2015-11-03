# Heteroplasmy

Introduction

This script utilizes existing NGS programs and streamlines their usage





Pre-requisites

Seqtk

$ git clone https://github.com/lh3/seqtk.git
$ cd seqtk
$ make
$ cp seqtk /usr/local/bin


Fastqutils - requires python. Run "$ sh init.sh" if the make step does not work.

$ git clone git://github.com/ngsutils/ngsutils.git 
$ cd ngsutils 
$ make
$ cd bin
$ cp ngsutils /usr/local/bin
