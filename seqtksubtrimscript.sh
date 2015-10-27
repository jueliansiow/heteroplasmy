#!/bin/sh


# find/define files and directories.
basedir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
fwd_reads=$(find $basedir -name '*R1*.gz')
rev_reads=$(find $basedir -name '*R2*.gz')
fwd_name=$(basename $fwd_reads)
rev_name=$(basename $rev_reads)


# Output file.
temp1=$basedir"/temp1.fq"
temp2=$basedir"/temp2.fq"
mergepe=$basedir"/mergepe.fq"
trim_mergepe=$basedir"/trim_mergepe.fq"
wsp_trim_mergepe=$basedir"/wsp_trim_mergepe.fq"
fwd_trim=$basedir"/fwd_trim.fq"
rev_trim=$basedir"/rev_trim.fq"
fwd_final_name=$basedir"/sub_$fwd_name"
rev_final_name=$basedir"/sub_$rev_name"


# Unzip the files
gzcat $fwd_reads > $temp1
gzcat $rev_reads > $temp2


# Interleave the pair end files
seqtk mergepe $temp1 $temp2 > $mergepe


# Run the quality trimming. Default is set to 0.05% probability.
seqtk trimfq $mergepe > $trim_mergepe


# Remove reads that have N's in it, reads below length threshold and do not have a pair.
fastqutils filter -wildcard 1 -size ${READLENGTH} -paired $trim_mergepe > $wsp_trim_mergepe


# Separate files. Not sure how to deal with this naming convention.
fastqutils unmerge $wsp_trim_mergepe temptrim


# Run the subset script.
seqtk sample -s100 temptrim.1.fastq ${NUM_READS} > $fwd_trim
seqtk sample -s100 temptrim.2.fastq ${NUM_READS} > $rev_trim


# Rename the files for final output
mv $fwd_trim $fwd_final_name
mv $rev_trim $rev_final_name


# Changing the file name of final output files to reflect that it isnt a .gz file.

for f in sub_*.fastq.gz; do echo mv $f `basename $f .fastq.gz`.fq; done


# Remove temporary files
rm $temp1
rm $temp2
rm $mergepe
rm $trim_mergepe
rm $subtrim_mergepe
rm temptrim.1.fastq
rm temptrim.2.fastq





# stop the script running the other processes
exit
















#options when running the script
for i in "$@"
do
case $i in
    -n=*|--num_reads=*)
    NUM_READS="${i#*=}"
    shift # past argument=value
    ;;
    -d=*|--directory=*)
    DIRECTORY="${i#*=}"
    shift # past argument=value
    ;;
    -o=*|--output=*)
    OUTPUT="${i#*=}"
    shift # past argument=value
    ;;
    -m=*|--minread_length=*)
    READLENGTH="${i#*=}"
    shift # past argument=value
    ;;
    --default)
    DEFAULT=YES
    shift # past argument with no value
    ;;
    *)
            # unknown option
    ;;
esac
done
echo "Number of reads  = ${NUM_READS}"
echo "Directory        = ${DIRECTORY}"
echo "OUTPUT           = ${LIBPATH}"
echo "READLENGTH       = ${READLENGTH}"
#echo "Number files in SEARCH PATH with EXTENSION:" $(ls -1 "${SEARCHPATH}"/*."${EXTENSION}" | wc -l)
#if [[ -n $1 ]]; then
#    echo "Last line of file specified as non-opt/last argument:"
#    tail -1 $1
#fi



