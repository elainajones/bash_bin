#! /bin/bash


get_sync_date() {
    target="/var/db/repos/gentoo";
    mod_date=$(ls -ldqgG --time-style="+%Y%m%d%H%M%S" $target | \
        grep -oP "\S+(?=\s$target)");

    echo $mod_date;
}

main() {
    # Limit in "YYYYmmddHHMMSS" format.
    sync_limit="00000002000000";
    # Log path to check sync messages
    # TODO: Check log to determine if portage
    #   should be updated. Update automatically.
    log_path="emerge-sync-$(date "+%F").log"

    today=$(date "+%Y%m%d%H%M%S");
    sync_date=$(get_sync_date);
    # Time means duration. Not the same as date.
    sync_time=$((today - sync_date));

    if [ $sync_time -gt $sync_limit ]; then
        sudo emerge --sync &>>$log_path &
    fi
}
main;
