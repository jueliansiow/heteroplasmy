#!/bin/sh


##### Parsing arguments to the rest of the file.

function show_help()
{
    echo "This is a pipeline to trim and subsample NGS raw data from a fastq.gz file using seqtk and fastquils. Seqtk and fastquils have to be installed and accessible from any directory prior to running this script."
    echo ""
    echo "./testingoptions.sh"
    echo "\t-h --help"
    echo "\t-o --outputdirectory= Enter the directory where files will be output to after analysis."
    echo "\t-i --inputdirectory= Enter the directory where the files are to be used for analysis."
    echo "\t-m --minreadlgth= Enter the mininum read length you would like to keep after trimming."
    echo ""
}

outputdirectory=
minreadlgth=
inputdirectory=

while :; do
    case $1 in
        -h|-\?|--help)   # Call a "show_help" function to display a synopsis, then exit.
            show_help
            exit
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
		-m|--minreadlgth)
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
            ;;        --)              # End of all options.
            shift
            break
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
            inputdirectory=${1#*=} # Delete everything up to "=" and assign the remainder.
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


##### 
echo Input_directory=$inputdirectory
echo Output_directory=$outputdirectory
echo Minimum_read_length=$minreadlgth


##### Suppose --numreads is a required option. Ensure the variable "file" has been set and exit if not.
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



##### find/define files and directories.
fwd_reads=$(find $inputdirectory -name '*R1*.gz')
rev_reads=$(find $inputdirectory -name '*R2*.gz')
fwd_name=$(basename $fwd_reads)
rev_name=$(basename $rev_reads)
tempfile="${fwd_name##*/}"


##### Output file.
temp1=$outputdirectory"/temp1.fq"
temp2=$outputdirectory"/temp2.fq"
mergepe=$outputdirectory"/mergepe.fq"
trim_mergepe=$outputdirectory"/trim_mergepe.fq"
wsp_trim_mergepe=$outputdirectory"/wsp_trim_mergepe.fq"


##### Message
echo "Starting trimming process. Unzipping files ..."


##### Unzip the files
gzcat $fwd_reads > $temp1
gzcat $rev_reads > $temp2


##### Message
echo "Merging files ..."


##### Interleave the pair end files
seqtk mergepe $temp1 $temp2 > $mergepe


##### Message
echo "Running quality trimming at 0.05% probability or a PHRED score of 13 ..."


##### Run the quality trimming. Default is set to 0.05% probability.
seqtk trimfq $mergepe > $trim_mergepe


##### Message
echo "Removing reads with N's, reads below length threshold $minreadlgth , and reads with no pair ..."


##### Remove reads that have N's in it, reads below length threshold and do not have a pair.
fastqutils filter -wildcard 1 -size $minreadlgth -paired $trim_mergepe > $wsp_trim_mergepe


##### Message
echo "Unmerging files ..."


##### Change the working directory so that the intermediate file is stored in the output directory.
cd $outputdirectory


##### Separate files. Not sure how to deal with this naming convention.
fastqutils unmerge $wsp_trim_mergepe unmerged_$(echo "${fwd_name%_*_*_*_*.*.*}")


##### Message
echo "Compressing files for output ..."


#### Rename the file where reads have been trimmed, N's removed, length checked and pairs checked.
mv $wsp_trim_mergepe trimmed_$(echo "${fwd_name%.*.*}").fastq


##### Gzip the files for final output.
gzip -1 unmerged_$(echo "${fwd_name%_*_*_*_*.*.*}").1.fastq
gzip -1 unmerged_$(echo "${fwd_name%_*_*_*_*.*.*}").2.fastq
gzip -1 trimmed_$(echo "${fwd_name%.*.*}").fastq


##### Message
echo "Cleaning up ..."


##### Remove temporary files
rm $temp1
rm $temp2
rm $mergepe
rm $trim_mergepe


##### Message
echo "Done"