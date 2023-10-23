#! /bin/bash

parse_args() {
    args=$@;
    declare -gA PARSED_ARGS=();
    for key in $(echo ${args[*]} | grep -oP "(^|[^\S])\-\S+"); do
        # Why am I like this?
        val=$(
            echo ${args[*]} | \
            grep -oP "(?<=$key).+?(?=\s\-|\Z|\s)" | \
            grep -oP "\S+" \
        );
        PARSED_ARGS["$key"]="$val";
    done    
}

print_help() {
    help_lines=(\
        "TODO: help" \
    );

    for i in ${!help_lines[*]}; do
        line=${help_lines[$i]};
        echo $line;
    done
}

 main() {
    args=$@;
    parse_args $args;
    
    if ! (( ${#PARSED_ARGS[@]} )); then
        print_help;
        exit 1;
    fi

    for key in ${!PARSED_ARGS[@]}; do
        val="${PARSED_ARGS[$key]}";
        case $key in
            "-i")
                declare input_file=$val;
                ;;
            "-o")
                declare output_file=$val;
                ;;
            "-h")
                print_help;
                ;;
            *)
                echo "invalid option '$key'"
                print_help;
                exit 1;
                ;;
        esac
    done 

}

main $@;
