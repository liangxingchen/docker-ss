#!/usr/bin/env bash

CLIENT_FLAG=${CLIENT_FLAG:-"false"}
SS_CONFIG=${SS_CONFIG:-""}
KCP_CONFIG=${KCP_CONFIG:-""}
KCP_FLAG=${KCP_FLAG:-"false"}

while getopts "s:k:xc" OPT; do
    case $OPT in
        s)
            SS_CONFIG=$OPTARG;;
        k)
            KCP_CONFIG=$OPTARG;;
        x)
            KCP_FLAG="true";;
        c)
            CLIENT_FLAG="true";;
    esac
done

if [ "$CLIENT_FLAG" == "true" ] && [ "$CLIENT_FLAG" != "" ]; then
    # client mode
    if [ "$KCP_FLAG" == "true" ] && [ "$KCP_CONFIG" != "" ]; then
        echo -e "\033[32mStarting kcptun client......\033[0m"
        kcptun-client $KCP_CONFIG 2>&1 &
    else
        echo -e "\033[33mKcptun client not started......\033[0m"
    fi

    echo -e "\033[32mStarting shadowsocks client......\033[0m"
    if [ "$SS_CONFIG" != "" ]; then
        ss-local $SS_CONFIG 2>&1 &
    else
        echo -e "\033[31mError: SS_CONFIG is blank!\033[0m"
        exit 1
    fi

    echo -e "\033[32mStarting privoxy client......\033[0m"
    privoxy --no-daemon --user privoxy /etc/privoxy/config

else

    if [ "$KCP_FLAG" == "true" ] && [ "$KCP_CONFIG" != "" ]; then
        echo -e "\033[32mStarting kcptun server......\033[0m"
        kcptun $KCP_CONFIG 2>&1 &
    else
        echo -e "\033[33mKcptun server not started......\033[0m"
    fi

    echo -e "\033[32mStarting shadowsocks server......\033[0m"
    if [ "$SS_CONFIG" != "" ]; then
        ss-server $SS_CONFIG
    else
        echo -e "\033[31mError: SS_CONFIG is blank!\033[0m"
        exit 1
    fi
fi
