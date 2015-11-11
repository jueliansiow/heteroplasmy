#!/bin/sh

##### Parsing arguments to the rest of the file.

function show_help()
{
    echo "This script will install seqtk and fastqutils to the directory that you have specify."
    echo ""
    echo "./installprereq.sh"
    echo "\t-h --help"
    echo "\t-i --installdirectory= Enter the directory where the files are to be installed."
    echo ""
}

installdirectory=

while :; do
    case $1 in
        -h|-\?|--help)   # Call a "show_help" function to display a synopsis, then exit.
            show_help
            exit
            ;;
		-i|--installdirectory)
            if [ -n "$2" ]; then
                installdirectory=$2
                shift 2
                continue
            else
                printf 'ERROR: "--installdirectory" requires a non-empty option argument.\n' >&2
                exit 1
            fi
            ;;
        --installdirectory=?*)
            installdirectory=${1#*=} # Delete everything up to "=" and assign the remainder.
            ;;
        --installdirectory=)         # Handle the case of an empty --file=
            printf 'ERROR: "--installdirectory" requires a non-empty option argument.\n' >&2
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
echo Install_directory=$installdirectory


##### Suppose --numreads is a required option. Ensure the variable "file" has been set and exit if not.

if [ -z "$installdirectory" ]; then
    printf 'ERROR: option "--installdirectory FILE" not given. See --help.\n' >&2
    exit 1
fi


##### Seqtk install
echo "Installing Seqtk ..."
cd $installdirectory
git clone https://github.com/lh3/seqtk.git
cd seqtk
make
export PATH=$PATH:"$(pwd)"


##### Fastqutils - requires python. Run "$ sh init.sh" if the make step does not work.
echo "Installing Fastqutils"
cd $installdirectory
git clone git://github.com/ngsutils/ngsutils.git 
cd ngsutils 
make
cd bin
export PATH=$PATH:"$(pwd)"
