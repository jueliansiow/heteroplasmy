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
    echo "\t-a --arc_config= Enter the path to the ARC config file that has been supplied with this script."
    echo "\t-r --arc_reference= Enter the path to the reference file that ARC needs for assembly
    echo ""
}

numreads=
outputdirectory=
arc_config=
inputdirectory=
arc_reference=

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
            
		-m|--arc_config)       # Takes an option argument, ensuring it has been specified.
            if [ -n "$2" ]; then
                arc_config=$2
                shift 2
                continue
            else
                printf 'ERROR: "--arc_config" requires a non-empty option argument.\n' >&2
                exit 1
            fi
            ;;
        --arc_config=?*)
            minreadlgth=${1#*=} # Delete everything up to "=" and assign the remainder.
            ;;
        --arc_config=)         # Handle the case of an empty --file=
            printf 'ERROR: "--arc_config" requires a non-empty option argument.\n' >&2
            exit 1
            ;;
		-r|--arc_reference)       # Takes an option argument, ensuring it has been specified.
            if [ -n "$2" ]; then
                arc_reference=$2
                shift 2
                continue
            else
                printf 'ERROR: "--arc_reference" requires a non-empty option argument.\n' >&2
                exit 1
            fi
            ;;
        --arc_reference=?*)
            minreadlgth=${1#*=} # Delete everything up to "=" and assign the remainder.
            ;;
        --arc_reference=)         # Handle the case of an empty --file=
            printf 'ERROR: "--arc_reference" requires a non-empty option argument.\n' >&2
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

if [ -z "$arc_config" ]; then
    printf 'ERROR: option "--arc_config FILE" not given. See --help.\n' >&2
    exit 1
fi

if [ -z "$inputdirectory" ]; then
    printf 'ERROR: option "--inputdirectory FILE" not given. See --help.\n' >&2
    exit 1
fi

if [ -z "$arc_reference" ]; then
    printf 'ERROR: option "--arc_reference FILE" not given. See --help.\n' >&2
    exit 1
fi

echo Input_directory=$inputdirectory
echo Output_directory=$outputdirectory
echo Number_of_reads=$numreads
echo Path_to_ARC_config=$arc_config
echo Path_to_ARC_reference=$arc_reference


##### find/define files and directories.
fwd_reads=$(find $inputdirectory -name 'unmerged*.1.fastq')
rev_reads=$(find $inputdirectory -name 'unmerged*.2.fastq')
fwd_name=$(basename $fwd_reads)
rev_name=$(basename $rev_reads)


##### Output file.
temp1=$outputdirectory"/temp1.fastq"
temp2=$outputdirectory"/temp2.fastq"


##### Unzip the files.
gzcat $fwd_reads > $temp1
gzcat $rev_reads > $temp2


##### Change the working directory.
cd $outputdirectory


##### Run the subset script.
seqtk sample -s100 $temp1 $numreads > fwd_trim.fastq
seqtk sample -s100 $temp2 $numreads > rev_trim.fastq


##### Copy the ARC_reference file from the specified path to the output directory and rename it.
cp $arc_reference $outputdirectory
mv $(basename $arc_reference) arcref.fa


##### Copy the ARC_config file from the specified path to the output directory and the run the ARC assembler.
cp $arc_config $outputdirectory
arc -c ./ARC_config.txt


##### Remove temporary files
rm $temp1
rm $temp2
rm arcref.fa

exit