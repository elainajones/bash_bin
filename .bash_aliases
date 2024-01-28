alias la='ls -AX --color --classify --group-directories-first'
alias lla='ls -lAshLX --color --classify --group-directories-first'

alias les='less -~KMQR-'

# Yes, I'm that lazy.
alias c='clear'
alias sba='source ~/.bash_aliases; exec bash'
alias vba='vim ~/.bash_aliases'
alias gpge='gpg --armour -e'

# (un)mount mtp devices (ie Android)
alias mmtp='jmtpfs ~/mtp && echo Device mounted at ~/mtp/ && thunar ~/mtp/'
alias ummtp='fusermount -u ~/mtp/'

alias oprts='sudo netstat -ntupl'

# Discord demands an update (gentoo users unite)
alias discup='sudo emerge --sync && sudo emerge discord'

alias ghist='history | grep'

#source ~/bin/qcd-SOURCEME.sh;

passgen() {
    declare pw_len=${1:-20};
    declare x_chars=$2;

    x_chars+="\n;,.\"\`\'"

    # Lazy stack overflow magic
    # https://stackoverflow.com/questions/27799024
    pass=$(LC_CTYPE=C < /dev/urandom tr -cd [:graph:] |\
        tr -d "$x_chars" | fold -w $pw_len | head -n 1);
    
    echo $pass | less;
}

doff() {
    declare opt=${1:-"-h"};

    if [[ "$opt" == "-h" ]]; then
    	echo "doff: used to power off block devices";
        echo "Usage: doff [/dev/sdX]";
        printf "\t-h\tPrint this help and exit.\n";
    elif [[ -b $opt ]]; then
        udisksctl power-off -b $opt;
    else
        echo "Invalid option";
    fi
    unset opt;
}

chroot-mnt() {
    declare opt=${1:-"-h"};

    if [[ "$opt" = "-h" ]]; then
    	echo "chroot-mnt: used to mount the necessary filesystems for chroot";
        echo "Usage: cm [chroot root]";
        printf "\t-h\tPrint this help and exit.\n";
    elif [[ -d $opt ]]; then
        sudo mount --types proc /proc $opt/proc;
	    sudo mount --rbind /sys $opt/sys;
	    sudo mount --make-rslave $opt/sys;
	    sudo mount --rbind /dev $opt/dev;
	    sudo mount --make-rslave $opt/dev;
	    sudo mount --bind /run $opt/run;
	    sudo mount --make-slave $opt/run;
	    printf "Filesystems mounted.\n"
	    printf "Remember to source /etc/profile after chroot.\n"
    else
        printf "Invalid option\n";
    fi
    
    unset opt
}

# Dumb fix if the mouse broke after hibernation on Debian.
# Keeping this just in case.
remouse() {
    sudo modprobe -r usbhid;
    sudo modprobe -r psmouse;
    sudo modprobe usbhid;
    sudo modprobe psmouse;
}

# I forgot how this works
# TODO: Some sort of help?
mcc() {
    declare path_in=${1};
    declare old_hex=${2};
    declare new_hex=${3};
    declare path_out=${4:-$(pwd)};

    for i in $(ls $path_in);
    do
        convert $path_in/$f -alpha deactivate \
            -fuzz 0% -fill "#$new_hex" -opaque "#$old_hex" \
            -alpha activate $path_out/$i;
    done;
}

tres() {
    if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
        echo "Usage: tres [dir:-pwd] [depth:-2] [optional tree flag]"
    else
        tree -aFCthR ${3} --dirsfirst --du --filelimit 200 \
            -L ${2:-2} -I ".git|*.swp" ${1:-$pwd} | \
            less -~KMQR-;
    fi
};

lac() {
    declare -i total=$(la ${1:-$pwd} | wc -l);
    declare -i f_num=$(find ${1:-$pwd} -maxdepth 1 -type f | wc -l);
    declare -i dir_num=$(find ${1:-$pwd} -maxdepth 1 -type d | wc -l);

    echo "$dir_num director$(
        if (( DIRECTORY_COUNT != 1 )); then
            echo "ies"
        else
            echo "y"
        fi
    ), $f_num file$(
        if (( $f_num != 1 )); then
            echo "s"
        fi
    ), $total total";
}

md2pdf() {
    pandoc "$1" \
        -f gfm \
        -V linkcolor:blue \
        -V geometry:a4paper \
        -V geometry:margin=2cm \
        -V mainfont="DejaVu Serif" \
        -V monofont="DejaVu Sans Mono" \
        --pdf-engine=xelatex \
        --highlight-style ~/bin/monochrome.theme \
        --include-in-header ~/bin/chapter-break.tex \
        --include-in-header ~/bin/inline-code.tex \
        --include-in-header ~/bin/bullet-list.tex \
        --css=github-pandoc.css \
        -o "$2"
}

