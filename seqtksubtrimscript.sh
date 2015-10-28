#!/bin/sh


##### Parsing arguments to the rest of the file.

function show_help()
{
    echo "This is a pipeline to trim and subsample NGS raw data from a fastq.gz file using seqtk and fastquils. Seqtk and fastquils have to be installed and accessible from any directory prior to running this script."
    echo ""
    echo "./testingoptions.sh"
    echo "\t-h --help"
    echo "\t-n --numreads = Enter the number of reads that you would like to end up with after sub sampling. The number can be a specific number of reads or a fraction of the reads in decimals."
    echo "\t-o --outputdirectory= Enter the directory where files will be output to after analysis."
    echo "\t-i --inputdirectory= Enter the directory where the files are to be used for analysis."
    echo "\t-m --minreadlgth= Enter the mininum read length you would like to keep after trimming."
    echo ""
}

numreads=
outputdirectory=
minreadlgth=
inputdirectory=

while :; do
    case $1 in
        -h|-\?|--help)   # Call a "show_help" function to display a synopsis, then exit.
            show_help
            exit
            ;;
        -n|--numreads)       # Takes an option argument, ensuring it has been specified.
            if [ -n "$2" ]; then
                numreads=$2
                shift 2
                continue
            else
                printf 'ERROR: "--numreads" requires a non-empty option argument.\n' >&2
                exit 1
            fi
            ;;
        --numreads=?*)
            numreads=${1#*=} # Delete everything up to "=" and assign the remainder.
            ;;
        --numreads=)         # Handle the case of an empty --file=
            printf 'ERROR: "--numreads" requires a non-empty option argument.\n' >&2
            exit 1
            ;;
            
        -o|--outputdirectory)
            if [ -n "$2" ]; then
                outputdirectory=$2
                shift 2
                continue
            else
                printf 'ERROR: "--outputdirectory" requires a non-empty option argument.\n' >&2
                exit 1
            fi
            ;;
        --outputdirectory=?*)
            outputdirectory=${1#*=} # Delete everything up to "=" and assign the remainder.
            ;;
        --outputdirectory=)         # Handle the case of an empty --file=
            printf 'ERROR: "--outputdirectory" requires a non-empty option argument.\n' >&2
            exit 1
            ;;        --)              # End of all options.
            shift
            break
            ;;
            
		-m|--minreadlgth)       # Takes an option argument, ensuring it has been specified.
            if [ -n "$2" ]; then
                minreadlgth=$2
                shift 2
                continue
            else
                printf 'ERROR: "--minreadlgth" requires a non-empty option argument.\n' >&2
                exit 1
            fi
            ;;
        --minreadlgth=?*)
            minreadlgth=${1#*=} # Delete everything up to "=" and assign the remainder.
            ;;
        --minreadlgth=)         # Handle the case of an empty --file=
            printf 'ERROR: "--minreadlgth" requires a non-empty option argument.\n' >&2
            exit 1
            ;;
		-i|--intputdirectory)
            if [ -n "$2" ]; then
                inputdirectory=$2
                shift 2
                continue
            else
                printf 'ERROR: "--inputdirectory" requires a non-empty option argument.\n' >&2
                exit 1
            fi
            ;;
        --inputdirectory=?*)
            outputdirectory=${1#*=} # Delete everything up to "=" and assign the remainder.
            ;;
        --inputdirectory=)         # Handle the case of an empty --file=
            printf 'ERROR: "--inputdirectory" requires a non-empty option argument.\n' >&2
            exit 1
            ;;        --)              # End of all options.
            shift
            break
            ;;
        -?*)
            printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
            ;;
        *)               # Default case: If no more options then break out of the loop.
            break
    esac

    shift
done

##### Suppose --numreads is a required option. Ensure the variable "file" has been set and exit if not.
if [ -z "$numreads" ]; then
    printf 'ERROR: option "--numreads FILE" not given. See --help.\n' >&2
    exit 1
fi

if [ -z "$outputdirectory" ]; then
    printf 'ERROR: option "--outputdirectory FILE" not given. See --help.\n' >&2
    exit 1
fi

if [ -z "$minreadlgth" ]; then
    printf 'ERROR: option "--minreadlgth FILE" not given. See --help.\n' >&2
    exit 1
fi

if [ -z "$inputdirectory" ]; then
    printf 'ERROR: option "--inputdirectory FILE" not given. See --help.\n' >&2
    exit 1
fi

echo $numreads
echo $outputdirectory
echo $minreadlgth
echo $inputdirectory


#### find/define files and directories.
fwd_reads=$(find $inputdirectory -name '*R1*.gz')
rev_reads=$(find $inputdirectory -name '*R2*.gz')
fwd_name=$(basename $fwd_reads)
rev_name=$(basename $rev_reads)


#### Output file.
temp1=$outputdirectory"/temp1.fq"
temp2=$outputdirectory"/temp2.fq"
mergepe=$outputdirectory"/mergepe.fq"
trim_mergepe=$outputdirectory"/trim_mergepe.fq"
wsp_trim_mergepe=$outputdirectory"/wsp_trim_mergepe.fq"
trimI=$outputdirectory"/trimI_$fwd_name"
fwd_trim=$outputdirectory"/fwd_trim.fq"
rev_trim=$outputdirectory"/rev_trim.fq"
fwd_final_name=$outputdirectory"/sub_$fwd_name"
rev_final_name=$outputdirectory"/sub_$rev_name"


#### Unzip the files
gzcat $fwd_reads > $temp1
gzcat $rev_reads > $temp2


#### Interleave the pair end files
seqtk mergepe $temp1 $temp2 > $mergepe


#### Run the quality trimming. Default is set to 0.05% probability.
seqtk trimfq $mergepe > $trim_mergepe


#### Remove reads that have N's in it, reads below length threshold and do not have a pair.
fastqutils filter -wildcard 1 -size $minreadlgth -paired $trim_mergepe > $wsp_trim_mergepe


#### Separate files. Not sure how to deal with this naming convention.
fastqutils unmerge $wsp_trim_mergepe temptrim


#### Rename the file where reads have been trimmed, N's removed, length checked and pairs checked.
mv $wsp_trim_mergepe $trimI
for f in trimI_*.fastq.gz; do mv $f `basename $f .fastq.gz`.fq; done


#### Run the subset script.
seqtk sample -s100 temptrim.1.fastq $numreads > $fwd_trim
seqtk sample -s100 temptrim.2.fastq $numreads > $rev_trim


#### Rename the files for final output
mv $fwd_trim $fwd_final_name
mv $rev_trim $rev_final_name


#### Changing the file name of final output files to reflect that it isnt a .gz file.
for f in sub_*.fastq.gz; do mv $f `basename $f .fastq.gz`.fq; done


#### gzip the files back up
gzip $(find $inputdirectory -name 'sub_*R1*.fq')
gzip $(find $inputdirectory -name 'sub_*R2*.fq')


#### Remove temporary files
rm $temp1
rm $temp2
rm $mergepe
rm $trim_mergepe
rm $subtrim_mergepe
rm temptrim.1.fastq
rm temptrim.2.fastq


