#!/bin/sh


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
#echo "LIBRARY PATH    = ${LIBPATH}"
#echo "Number files in SEARCH PATH with EXTENSION:" $(ls -1 "${SEARCHPATH}"/*."${EXTENSION}" | wc -l)
#if [[ -n $1 ]]; then
#    echo "Last line of file specified as non-opt/last argument:"
#    tail -1 $1
#fi


# find/define files and directories.
basedir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
fwd_reads=$(find $basedir -name '*R1*.gz')
rev_reads=$(find $basedir -name '*R2*.gz')


# Unzip the files
#gzcat $fwd_reads
#gzcat $fwd_reads


fwd_name=$(basename $fwd_reads)
rev_name=$(basename $rev_reads)


# Output file.
fwd_unzip=$basedir"/unzip_$fwd_name"
rev_unzip=$basedir"/unzip_$rev_name"
fwd_trim=$basedir"/trim_$fwd_name"
rev_trim=$basedir"/trim_$rev_name"
fwd_subtrim=$basedir"/subtrim_$fwd_name"
rev_subtrim=$basedir"/subtrim_$rev_name"


# Changing the file format from .fastq to .fq so that seqtk accepts the file.
# Apparently not needed. Can use to remove .gz from file name.
# Need to be careful when choosing file names.
# for f in *.fastq.gz; do mv $f `basename $f .fastq.gz`.fq; done


# Interleave the pair end files
#seqtk mergepe $fwd_reads $rev_reads


# Run the quality trimming. Default is set to 0.05% probability.
#seqtk trimfq $fwd_reads > $fwd_trim
#seqtk trimfq $rev_reads > $rev_trim


# Run the subset script.
#seqtk sample -s100 $fwd_trim ${NUM_READS} > $fwd_subtrim
#seqtk sample -s100 $rev_trim ${NUM_READS} > $rev_subtrim




