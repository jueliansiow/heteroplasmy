#!/bin/sh


# How many reads do you want to end up with?
read -e -p "Enter a fraction (in decimals) or the number of reads you would like: " numreads


#changing the file format from .fastq to .fq so that seqtk accepts the file. Apparently not needed.
#for f in *.fastq; do mv $f `basename $f .fastq`.fq; done

# find/define files and directories.
basedir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
fwd_reads=$(find $basedir -name '*R1*')
rev_reads=$(find $basedir -name '*R2*')
fwd_name=$(basename $fwd_reads)
rev_name=$(basename $rev_reads)

# Output file.
fwd_trim=$basedir"/trim_$fwd_name"
rev_trim=$basedir"/trim_$rev_name"
fwd_subtrim=$basedir"/sub_$fwd_name"
rev_subtrim=$basedir"/sub_$rev_name"

# Run the quality trimming. Default is set to 0.05% probability.
seqtk trimfq $fwd_reads > $fwd_trim
seqtk trimfq $rev_reads > $rev_trim


# Run the subset script.
seqtk sample -s100 $fwd_trim $numreads > $fwd_subtrim
seqtk sample -s100 $rev_trim $numreads > $rev_subtrim




