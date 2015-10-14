#!/bin/sh

# find/define files and directories
basedir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
basedir=$basedir'/'
fwd_reads=$(find $basedir -name '*R1*')
rev_reads=$(find $basedir -name '*R2*')


# The fraction of number that you want to sub sample to. Need to figure out how to tell the sh script what the number is.
frac=$


# Output file
fwd_subset=$basedir"sub$fwd_reads"
rev_subset=$basedir"sub$rev_reads"
fwd_subtrim=$basedir"subtrim$fwd_reads"
rev_subtrim=$basedir"subtrim$rev_reads"


# Count the number of lines in a file and write to a file.
wc -l $fwd_reads > fwdreadcount
wc -l $fwd_reads > revreadcount


# Remove file name from the line count and divide by 4 and write to a new file.
sed '1s/$fwd_reads//' fwdreadcount | expr `head` / 4 > fwddivreadcount
sed '1s/$rev_reads//' revreadcount | expr `head` / 4 > revdivreadcount


# Run the subset script
perl subset_fastq.pl --input $fwd_reads --output $fwd_subset --fraction $frac --length `tail +1 fwddivreadcount`
perl subset_fastq.pl --input $rev_reads --output $rev_subset --fraction $frac --length `tail +1 revdivreadcount`


#remove intermediate files
rm fwdreadcount
rm revreadcount
rm fwddivreadcount
rm revdivreadcount


# Trim subsampled files
seqtk trimfq $fwd_subset > $fwd_subtrim
seqtk trimfq $rev_subset > $rev_subtrim