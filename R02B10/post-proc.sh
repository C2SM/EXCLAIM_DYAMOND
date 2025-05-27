EXPDIR=${EXPDIR:-"/capstor/scratch/cscs/leclairm/DYAMOND_experiments/Benchmark_R02B10/with_IO/member_1/Benchmark_200_31"}

[ -z "${YYYY}" ] && (echo "ERROR: year not set")
[ -z "${MM}" ] && (echo "ERROR: month not set")

pushd "${EXPDIR}" >/dev/null 2>&1 || exit 1
echo "Post processing experiment ${EXPDIR}"
echo

# Loop over output directories
find . -type d -name 'out_*' -print0 | while read -r -d $'\0' out_dir; do

    # Enter output stream directory
    pushd "${out_dir}" >/dev/null 2>&1 || exit 1
    echo "Post-processing stream ${out_dir}"

    # Create postproc directory where we write post-processed files
    mkdir -p "postproc"
    # Workaround for wrong quota issue
    lfs setstripe -i 0 -c 20 "./postproc"

    # Store list of files to handle during this executaion of the script to avoid race conditions
    ls *_${YYYY}${MM}[0-3][0-9]T[0-2][0-9][0-5][0-9][0-5][0-9]*Z.nc > file_list

    # Check integrity of the files and get variable list
    echo
    echo "  Checking file sizes"
    first_file="true"
    while read -r nc_file; do
        echo "    ${nc_file}"
        size=$(stat --printf="%s" ${nc_file})
        if [ "${first_file}" == "true" ]; then
            ref_size="${size}"
            vars=($(cdo -showname "${nc_file}" | head -n 1))
        elif [ "${size}" != "${ref_size" ]; then
            echo "    ERROR: file size not matching reference"
            exit 1
        fi
        first_file="false"
    done < file_list

    # Check if we're handling a stream with a single variable
    if [ ${#vars[@]} == 1 ]; then
        echo
        echo "  Single variable in this stream, only renaming"
        var=${var[0]}
        while read -r nc_file; do
            echo "    ${nc_file}"
            date_nc=${nc_file##*_}
            mv ${nc_file} "./postproc/${var}_${date_nc}"
        done < file_list
        exit 0
    fi

    # Extract variables to their own files
    echo
    echo "  Extracting variables"

    # Array to store reference extracted var file sizes
    unset ref_var_file_size
    declare -A ref_var_file_size

    # Iterate over files
    first_file="true"
    while read -r nc_file; do
        echo "    processing file ${nc_file}"

        # Store file suffix
        date_nc=${nc_file##*_}

        # Iterate over variables
        for var in ${vars[@]}; do
            echo "      extracting var ${var}"

            # Extract var to own file
            var_file="./postproc/${var}_${date_nc}"
            ncrcat -h -v "${var}" "${nc_file}" "${var_file}"
            if [ "$?" != 0 ]; then
                echo "      ERROR while extracting ${var} from ${nc_file}"
                exit 1
            fi

            # Check extracted var file size or store as reference
            var_file_size=$(stat --printf="%s" ${var_file})
            if [ "${first_file}" == "true" ]; then
                ref_var_file_size["${var}"]=${var_file_size}
            elif [ "${var_file_size}" != "${ref_var_file_size["${var}"]}" ]; then
                echo "      ERROR: var_file_size not matching reference"
                exit 1
            fi
        done
        first_file="false"
    done < file_list

    # Delete original files
    echo
    echo "  Deleting original files"
    while read -r nc_file; do
        rm ${nc_file}
    done < file_list

    # Exit output stream directory
    popd >/dev/null 2>&1 || exit 1

done
