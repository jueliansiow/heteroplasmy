#!/bin/sh


##### Parsing arguments to the rest of the file.


function show_help()
{
    echo "This is a pipeline that takes the triming and subsampling script and runs it on all folders in a directory."
    echo ""
    echo "./testingoptions.sh"
    echo "\t-h --help"
    echo "\t-n --num_reads= Enter the number of reads that you would like to end up with after sub sampling. The number can be a specific number of reads or a fraction of the reads in decimals."
    echo "\t-d --outdirectory= Enter the directory where files will be output to after analysis."
    echo "\t-f --folderdirectory= Enter the directory where the files are to be used for analysis."
    echo "\t-a --arc_config= Enter the path to the ARC config file that has been supplied with this script."
    echo "\t-r --arc_reference= Enter the path to the reference file that ARC needs for assembly"
    echo "\t-k --min_readlgth= Enter the mininum read length you would like to keep after trimming."
    echo "\t-t --trimscript= Enter the path to where the trimming script lives."
    echo "\t-s --arc_script= Enter the path to where the arc script lives."
    echo ""
}

num_reads=
outdirectory=
arc_config=
arc_reference=
folderdirectory=
trimscript=
min_readlgth=
arc_script=


while :; do
    case $1 in
        -h|-\?|--help)   # Call a "show_help" function to display a synopsis, then exit.
            show_help
            exit
            ;;
        -n|--num_reads)       # Takes an option argument, ensuring it has been specified.
            if [ -n "$2" ]; then
                num_reads=$2
                shift 2
                continue
            else
                printf 'ERROR: "--num_reads" requires a non-empty option argument.\n' >&2
                exit 1
            fi
            ;;
        --num_reads=?*)
            num_reads=${1#*=} # Delete everything up to "=" and assign the remainder.
            ;;
        --num_reads=)         # Handle the case of an empty --file=
            printf 'ERROR: "--num_reads" requires a non-empty option argument.\n' >&2
            exit 1
            ;;
        -d|--outdirectory)
            if [ -n "$2" ]; then
                outdirectory=$2
                shift 2
                continue
            else
                printf 'ERROR: "--outdirectory" requires a non-empty option argument.\n' >&2
                exit 1
            fi
            ;;
        --outdirectory=?*)
            outdirectory=${1#*=} # Delete everything up to "=" and assign the remainder.
            ;;
        --outdirectory=)         # Handle the case of an empty --file=
            printf 'ERROR: "--outdirectory" requires a non-empty option argument.\n' >&2
            exit 1
            ;;        --)              # End of all options.
            shift
            break
            ;;
		-k|--min_readlgth)       # Takes an option argument, ensuring it has been specified.
            if [ -n "$2" ]; then
                min_readlgth=$2
                shift 2
                continue
            else
                printf 'ERROR: "--min_readlgth" requires a non-empty option argument.\n' >&2
                exit 1
            fi
            ;;
        --min_readlgth=?*)
            min_readlgth=${1#*=} # Delete everything up to "=" and assign the remainder.
            ;;
        --min_readlgth=)         # Handle the case of an empty --file=
            printf 'ERROR: "--min_readlgth" requires a non-empty option argument.\n' >&2
            exit 1
            ;;            
		-a|--arc_config)       # Takes an option argument, ensuring it has been specified.
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
            arc_config=${1#*=} # Delete everything up to "=" and assign the remainder.
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
            arc_reference=${1#*=} # Delete everything up to "=" and assign the remainder.
            ;;
        --arc_reference=)         # Handle the case of an empty --file=
            printf 'ERROR: "--arc_reference" requires a non-empty option argument.\n' >&2
            exit 1
            ;;
		-f|--folderdirectory)
            if [ -n "$2" ]; then
                folderdirectory=$2
                shift 2
                continue
            else
                printf 'ERROR: "--folderdirectory" requires a non-empty option argument.\n' >&2
                exit 1
            fi
            ;;
        --folderdirectory=?*)
            folderdirectory=${1#*=} # Delete everything up to "=" and assign the remainder.
            ;;
        --folderdirectory=)         # Handle the case of an empty --file=
            printf 'ERROR: "--inputdirectory" requires a non-empty option argument.\n' >&2
            exit 1
            ;;        --)              # End of all options.
            shift
            break
            ;;
        -s|--arc_script)
            if [ -n "$2" ]; then
                arc_script=$2
                shift 2
                continue
            else
                printf 'ERROR: "--arc_script" requires a non-empty option argument.\n' >&2
                exit 1
            fi
            ;;
        --arc_script=?*)
            arcscript=${1#*=} # Delete everything up to "=" and assign the remainder.
            ;;
        --arc_script=)         # Handle the case of an empty --file=
            printf 'ERROR: "--arc_script" requires a non-empty option argument.\n' >&2
            exit 1
            ;;        --)              # End of all options.
            shift
            break
            ;;
		-t|--trimscript)
            if [ -n "$2" ]; then
                trimscript=$2
                shift 2
                continue
            else
                printf 'ERROR: "--trimscript" requires a non-empty option argument.\n' >&2
                exit 1
            fi
            ;;
        --trimscript=?*)
            trimscript=${1#*=} # Delete everything up to "=" and assign the remainder.
            ;;
        --trimscript=)         # Handle the case of an empty --file=
            printf 'ERROR: "--trimscript" requires a non-empty option argument.\n' >&2
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



echo Out_directory=$outdirectory
echo Folder_directory=$folderdirectory
echo Number_of_reads=$num_reads
echo Minium_read_length=$min_readlgth
echo Path_to_ARC_config=$arc_config
echo Path_to_ARC_reference=$arc_reference
echo Path_to_trimming_script=$trimscript
echo Path_to_arc_script=$arc_script



##### Suppose --numreads is a required option. Ensure the variable "file" has been set and exit if not.
if [ -z "$num_reads" ]; then
    printf 'ERROR: option "--num_reads Number" not given. See --help.\n' >&2
    exit 1
fi

if [ -z "$outdirectory" ]; then
    printf 'ERROR: option "--outdirectory Path" not given. See --help.\n' >&2
    exit 1
fi

if [ -z "$arc_config" ]; then
    printf 'ERROR: option "--arc_config Path" not given. See --help.\n' >&2
    exit 1
fi

if [ -z "$folderdirectory" ]; then
    printf 'ERROR: option "--folderdirectory Path" not given. See --help.\n' >&2
    exit 1
fi

if [ -z "$arc_reference" ]; then
    printf 'ERROR: option "--arc_reference Path" not given. See --help.\n' >&2
    exit 1
fi

if [ -z "$min_readlgth" ]; then
    printf 'ERROR: option "--min_readlgth Number" not given. See --help.\n' >&2
    exit 1
fi

if [ -z "$trimscript" ]; then
    printf 'ERROR: option "--trimscript Path" not given. See --help.\n' >&2
    exit 1
fi

if [ -z "$arc_script" ]; then
    printf 'ERROR: option "--arc_script Path" not given. See --help.\n' >&2
    exit 1
fi


cd $folderdirectory


for f in Sample_*
do 
	echo "... Processing $f file ..."
	mkdir -p $outdirectory/$f/trim
	cd $f
	sh $trimscript -i $(pwd) -m $min_readlgth -o $outdirectory/$f/trim
	cd $folderdirectory
	mkdir -p $outdirectory/$f/ARC
	sh $arcscript -i $outdirectory/$f/trim -n $num_reads -o $outdirectory/$f/ARC -a $arc_config -r $arc_reference
	echo "Completed processing $f file."
	
done

echo "Completed processing all files in $folderdirectory"