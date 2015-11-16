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
    echo "\t-l --lowkmer= Enter the lowest kmer value to calculate from. Has to be an odd number"
    echo "\t-a --interval= Enter the interval between kmer values which will be calculated. Has to be an even number."
    echo "\t-k --highkmer= Enter the highest kmer value to calculate to. Has to be an odd number."
    echo "\t-g --velvetgoptions= Enter the options that you want velvetg to run. You must include double quotation marks. "[-cov_cutoff value] [-min_contig_lgth value] [-exp_cov value]". Refer to the velvet manual for a full list of options. The clean option has already been added."
    echo ""
}

outputdirectory=
interval=
lowkmer=
highkmer=
velvetgoptions=
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
		-l|--lowkmer)
            if [ -n "$2" ]; then
                lowkmer=$2
                shift 2
                continue
            else
                printf 'ERROR: "--lowkmer" requires a non-empty option argument.\n' >&2
                exit 1
            fi
            ;;
        --lowkmer=?*)
            lowkmer=${1#*=} # Delete everything up to "=" and assign the remainder.
            ;;
        --lowkmer=)         # Handle the case of an empty --file=
            printf 'ERROR: "--lowkmer" requires a non-empty option argument.\n' >&2
            exit 1
            ;;        --)              # End of all options.
            shift
            break
            ;;
		-a|--interval)
            if [ -n "$2" ]; then
                interval=$2
                shift 2
                continue
            else
                printf 'ERROR: "--interval" requires a non-empty option argument.\n' >&2
                exit 1
            fi
            ;;
        --interval=?*)
            interval=${1#*=} # Delete everything up to "=" and assign the remainder.
            ;;
        --interval=)         # Handle the case of an empty --file=
            printf 'ERROR: "--interval" requires a non-empty option argument.\n' >&2
            exit 1
            ;;        --)              # End of all options.
            shift
            break
            ;;
        -k|--highkmer)
            if [ -n "$2" ]; then
                highkmer=$2
                shift 2
                continue
            else
                printf 'ERROR: "--highkmer" requires a non-empty option argument.\n' >&2
                exit 1
            fi
            ;;
        --highkmer=?*)
            highkmer=${1#*=} # Delete everything up to "=" and assign the remainder.
            ;;
        --highkmer=)         # Handle the case of an empty --file=
            printf 'ERROR: "--highkmer" requires a non-empty option argument.\n' >&2
            exit 1
            ;;        --)              # End of all options.
            shift
            break
            ;;
        -g|--velvetgoptions)
            if [ -n "$2" ]; then
                velvetgoptions=$2
                shift 2
                continue
            else
                printf 'ERROR: "--velvetgoptions" requires a non-empty option argument.\n' >&2
                exit 1
            fi
            ;;
        --velvetgoptions=?*)
            velvetgoptions=${1#*=} # Delete everything up to "=" and assign the remainder.
            ;;
        --velvetgoptions=)         # Handle the case of an empty --file=
            printf 'ERROR: "--velvetgoptions" requires a non-empty option argument.\n' >&2
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
echo Low_kmer=$lowkmer
echo Inverval=$interval
echo High_kmer=$highkmer
echo Velvetg_options=$velvetgoptions


##### Suppose --numreads is a required option. Ensure the variable "file" has been set and exit if not.
if [ -z "$outputdirectory" ]; then
    printf 'ERROR: option "--outputdirectory FILE" not given. See --help.\n' >&2
    exit 1
fi

if [ -z "$lowkmer" ]; then
    printf 'ERROR: option "--lowkmer FILE" not given. See --help.\n' >&2
    exit 1
fi

if [ -z "$interval" ]; then
    printf 'ERROR: option "--interval FILE" not given. See --help.\n' >&2
    exit 1
fi

if [ -z "$highkmer" ]; then
    printf 'ERROR: option "--highkmer FILE" not given. See --help.\n' >&2
    exit 1
fi

if [ -z "$inputdirectory" ]; then
    printf 'ERROR: option "--inputdirectory FILE" not given. See --help.\n' >&2
    exit 1
fi


##### find/define files and directories.
fwd_reads=$(find $inputdirectory -name '*.1.fastq')
rev_reads=$(find $inputdirectory -name '*.2.fastq')
fwd_name=$(basename $fwd_reads)
rev_name=$(basename $rev_reads)


##### Message
echo "Name_of_forward_file=$fwd_name"
echo "Name_of_reverse_file=$rev_name"
echo "Running velveth pre-processing"


##### Change directory
cd $inputdirectory


##### Running velveth on a range of different kmer values.
velveth $outputdirectory/ $lowkmer,$highkmer,$interval -fastq -shortPaired -separate $fwd_name $rev_name -noHash


##### Message
echo "Velvet pre-processing completed. Now running velveth" 


##### Running velveth on the kmer values that have been pre-calculated.
velveth $outputdirectory/ $lowkmer,$highkmer$interval, -reuse_Sequences


##### Message
echo "Velveth completed. Now running velvetg" 


##### Changed the directory
cd $outputdirectory


##### Run velvetg on all folders which velveth has been completed.
for f in _*
do 
	echo "... Processing $f file ..."
	velvetg $outputdirectory/$f $velvetgoptions -clean yes
	sed -n '24p;34p' $outputdirectory/$f/log >> $outputdirectory/compiledvelvetresults
	echo "Completed processing $f file."
	
done


##### Complete.
echo "Velvet script complete"