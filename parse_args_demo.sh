#! /bin/bash

parse_args() {
    args=$@;
    declare -Ag CONFIG=();
    for key in $(echo ${args[*]} | grep -oP "\B\-\S+"); do
        # Why am I like this?
        val=$(echo ${args[*]} | \
            grep -oP "(?<=$key).+?(?=\B\-|\Z)" | \
            grep -oP "\S(.*|\s)\S+");
        CONFIG["$key"]="$val";
    done
}

print_help() {
    lines=(\
        "Usage: parse_args_demo [OPTIONS]" \
        "" \
        "  Example CLI application to demonstrate parsing args." \
        "" \
        "Options:" \
        "  -h, --help\tShow this message and exit." \
        "  -i, --input\tInput." \
        "  -o, --output\tOutput." \
    );

    for i in ${!lines[@]}; do
        line=${lines[$i]};
        printf "$line\n";
    done
}

main() {
    args=$@;
    parse_args $args;

    if ! [[ "$args" ]] || ! [[ "${!CONFIG[@]}" ]]; then
        print_help;
        exit 0;
    fi

    declare input="";
    declare output="";

    for key in "${!CONFIG[@]}"; do
        val="${CONFIG[$key]}";
        case $key in
            "-i")
                input=$val;
                ;;
            "--input")
                input=$val;
                ;;
            "-o")
                output=$val;
                ;;
            "--output")
                output=$val;
                ;;
            "-h")
                print_help;
                exit 0;
                ;;
            "--help")
                print_help;
                exit 0;
                ;;
            *)
                echo "Invalid option '$key'";
                echo "Try '--help' for more information.";
                exit 1;
        esac
    done

    echo "Input: '$input'";
    echo "Output: '$output'";
}

main $@;
