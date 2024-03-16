#! /bin/bash
#
#
# NAME
#       qcd - quickly cd
# 
# SYNOPSIS
#       qcd [OPTION] SHORTCUT
#
# DESCRIPTION
#       Bash utility for saving directory paths for corresponding 
#       directory shortcut names. The directory shortcut names are 
#       used in place of the full paths for a more convenient method 
#       of navigating to frequently used directories.
#
#       -h      print help and exit
#       -a      add shortcut for current dir
#       -d	    delete shortcut
#
# AUTHOR
#       Written by Elaina Jones
#
# You will need to source this file for it to work properly since 
# directory changes otherwise occur in a subshell rather than taking 
# effect in the current process. The use of inner functions are 
# defined to avoid polluting global namespace.

qcd() {
    print_help() {
        lines=(\
            "Usage: qcd [OPTION] SHORTCUT" \
            "" \
            "  qcd - quickly cd using saved directory shortcuts." \
            "" \
            "Options:" \
            "  -h, --help\tShow this message and exit." \
            "  -a SHORTCUT\tAdd shortcut for current directory." \
            "  -d SHORTCUT\tDelete shortcut." \
        );
    
        for i in ${!lines[@]}; do
            line=${lines[$i]};
            printf "$line\n";
        done
    }
    require_val() {
        declare key="$1";
        declare val="$2";
        if ! [[ "$val" ]]; then
            echo "Option '$key' requires an argument";
            echo "Try '--help' for more information.";
            return 1;
        fi
        return 0
    }
    parse_args() {
        args="$@";
        declare -Ag ARGS=();
        declare keys=($(echo $args | grep -oP "\B\-\S+"));
        for i in $(seq 1 ${#keys[@]}); do
            declare key="${keys[$((i-1))]}";
            # 1. Use variable keys to match everything up to the next 
            #    variable key as the variable value.
            # 2. Remove leading/trailing whitespace.
            #TODO: var is only first arg after key. Fine for most cases.
            if [[ "${keys[$i]}" ]]; then
                declare val="$(\
                    echo $args | \
                    grep -oP "(?<=$key\s).+?(?=${keys[$i]}\s)" | \
                    grep -oP "\S.*" | grep -oP ".*\S" \
                )";
            else
                declare val="$(\
                    echo $args | \
                    grep -oP "(?<=$key\s).+?(?=\Z)" | \
                    grep -oP "\S.*" | grep -oP ".*\S" \
                )";
            fi
            ARGS["$key"]="$val";
        done
    }
    print_shortcuts() {
        if [[ ${#CONFIG[@]} -eq 0 ]]; then
            echo "No saved directories";
        else
            for key in "${!CONFIG[@]}"; do
                val="${CONFIG[$key]}";
                printf "$key\t$val\n";
            done
        fi
    }
    read_config() {
        declare config_path=$1;
        declare -gA CONFIG=();
        if [[ -f $config_path ]]; then
            source $config_path;
        fi
    }
    write_config() {
        declare config_path=$1;
        echo "# DO NOT EDIT! File generated by script" > $config_path;
        echo "CONFIG=(\\" >> $config_path;
        for key in "${!CONFIG[@]}"; do
            val="${CONFIG[$key]}";
            printf "\t[\"$key\"]=\"$val\" \\" >> $config_path;
            printf "\n" >> $config_path;
        done
        echo ")" >> $config_path;
    }
    # Adds shortcut for current directory to cd_shortcuts.
    add_shortcut() {
        declare shortcut="$1";
        # Don't overwrite existing shortcuts
        if [[ "$shortcut" ]]; then
            if ! [[ "${CONFIG[$shortcut]}" ]]; then
                declare -gA CONFIG["$shortcut"]="$PWD";
                echo "Added '$shortcut'";
            else
                echo "Shortcut already exists";
            fi
        fi
    }
    delete_shortcut() {
        declare shortcut="$1";
        if [[ "${CONFIG["$shortcut"]}" ]]; then
            unset CONFIG["$shortcut"];
            echo "Deleted '$shortcut'";
        else
            echo "No such shortcut";
        fi
    }
    
    parse_args "$@";
    declare arg_count=($@);
    declare arg_count=${#arg_count[@]};

    declare config_path=~/bin/qcd.dat;
    mkdir -p $(dirname $config_path);
    read_config $config_path;

    for key in "${!ARGS[@]}"; do
        val="${ARGS[$key]}";
        case $key in
            "-a")
                require_val "$key" "$val";
                add_shortcut "$val";
                write_config $config_path;
                break;
                ;;
            "-d")
                require_val "$key" "$val";
                delete_shortcut "$val";
                write_config $config_path;
                break;
                ;;
            "-h")
                print_help;
                break;
                ;;
            "--help")
                print_help;
                break;
                ;;
            *)
                echo "Invalid option '$key'";
                echo "Try '--help' for more information.";
                break;
        esac
    done

    if ! [[ "${!ARGS[@]}" ]]; then
        if [[ $arg_count -eq 0 ]]; then
            print_shortcuts;
        elif [[ $arg_count -eq 1 ]]; then
            if [[ "${CONFIG["$1"]}" ]]; then
                dir_name="${CONFIG["$1"]}";
                if [[ -d "$dir_name" ]]; then
                    cd "$dir_name";
                else
                    echo "Directory moved or missing";
                fi
            else
                echo "No such shortcut";
            fi
        elif [[ $arg_count -gt 1 ]]; then
            echo "Too many arguments";
        fi
    fi
}

