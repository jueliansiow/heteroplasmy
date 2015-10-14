#!/bin/sh


# find/define files and directories
basedir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
basedir=$basedir'/'
fwd_reads=$(find $basedir -name '*R1*')
rev_reads=$(find $basedir -name '*R2*')

# How many reads do you want to end up with?
num_reads=


# Output file
fwd_subset=$basedir"sub$fwd_reads"
rev_subset=$basedir"sub$fwd_reads"
fwd_subtrim=$basedir"subtrim$fwd_reads"
rev_subtrim=$basedir"subtrim$rev_reads"


# Run the subset script
seqtk sample -s100 $fwd_reads $num_reads > $fwd_subset
seqtk sample -s100 $fwd_reads $num_reads > $rev_subset


# Run the quality trimming. Default is set to 0.05% probability.
seqtk trimfq $fwd_subset > $fwd_subtrim
seqtk trimfq $rev_subset > $rev_subtrim

