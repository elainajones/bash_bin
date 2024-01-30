#! /bin/bash


get_latest_ver() {
    url="https://packages.gentoo.org/packages/net-im/discord";
    html=$(curl --no-progress-meter $url);
    versions=($(echo $html | \
        grep -ioP "available versions.*</table" | \
        grep -ioP "<a.*?kk-ebuild.*?</a" | \
        grep -oP "(?<=>).*?(?=<)")
    )
    latest=${versions[0]}

    echo $latest
}

get_installed_ver() {
    installed=$(emerge --pretend --search net-im/discord | \
        grep -ioP "version installed.*" | \
        grep -oP "\S*$" | \
        grep -oP "\S(.*|\s)\S+");

    echo $installed
}

main() {
    installed=$(get_installed_ver);
    latest=$(get_latest_ver);

    echo "$installed installed";
    echo "$latest available";
    
    if [[ "$latest" != "$installed" ]]; then
        # New version available to upgrade.
        sudo emerge --sync && \
            sudo emerge net-im/discord;
        discord;
    else
        # No new versions, use portable tar.gz
        url="https://discord.com/api/download/"`
            `"stable?platform=linux&format=tar.gz";
        # Parse redirect for actual download link.
        url=$(curl --no-progress-meter $url | \
            grep -oP "(?<=href=\").*?(?=\">)");
        file=$(basename $url);
    
        temp_dir=$(mktemp -d);
        wget -q -O $temp_dir/$file -o /dev/null $url;
        tar -xf $temp_dir/$file -C $temp_dir;
    
        # Never assume anything.
        path=$(find $temp_dir -type f -name "Discord");
        chmod +x $path;
        $path &>/dev/null;
    fi
}
main;
