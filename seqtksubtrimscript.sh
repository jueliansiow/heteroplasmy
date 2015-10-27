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
trim_mergepeonly=$basedir"/trim_mergepeonly.fq"
subtrim_mergepe=$basedir"/subtrim_mergepe.fq"


# Unzip the files
gzcat $fwd_reads > $temp1
gzcat $rev_reads > $temp2


# Changing the file format from .fastq to .fq so that seqtk accepts the file.
# Apparently not needed. Can use to remove .gz from file name.
# Need to be careful when choosing file names.
#        for f in *.fastq.gz; do mv $f `basename $f .fastq.gz`.fq; done


# Interleave the pair end files
seqtk mergepe $temp1 $temp2 > $mergepe


# Run the quality trimming. Default is set to 0.05% probability.
seqtk trimfq $mergepe > $trim_mergepe


# Remove reads that have N's in it, reads below length threshold and do not have a pair.
fastqutils filter -wildcard 1 -size ${READLENGTH} -paired $trim_mergepe > $wsp_trim_mergepe


# Separate files
# fastqutils split -ignorepaired $trim_mergepeonly trim


# Run the subset script.
seqtk sample -s100 $trim_mergepe ${NUM_READS} > $subtrim_mergepe


# Remove temporary files
rm $temp1
rm $temp2
rm $mergepe
rm $trim_mergepe
rm $subtrim_mergepe





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



