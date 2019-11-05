#!/bin/bash

APPROOT="ROOTDIR"

. $APPROOT/lib/monitors.inc.sh

genall() {
	MONLIST	
}

availres=(RESLIST)
availact=(GET)
read request
action=$(printf "$request" | awk '{ print $1 }')
resource=$(printf "$request" | awk '{ print $2 }')

if [ -z "$(which iostat)" ]; then
        read -r -d '' RESPBODY <<HERE
{ "error":"command iostat unavailable" }
HERE
        echo "HTTP/1.1 500 Internal Server Error"
        echo "Content-Length: ${#RESPBODY}"
        echo "Date: $(date -Ru)"
        echo ""
        echo "$RESPBODY"
elif [ -z "$(awk -v thisact="$action" 'BEGIN { RS=" " } { if (thisact == $1) { print thisact } }' <<< "${availact[@]}")" ]; then
        read -r -d '' RESPBODY <<HERE
{ "error":"invalid HTTP method ($action)" }
HERE
        echo "HTTP/1.1 500 Internal Server Error"
        echo "Content-Length: ${#RESPBODY}"
        echo "Date: $(date -Ru)"
        echo ""
        echo "$RESPBODY"
elif [ -z "$(awk -v thisres="$resource" 'BEGIN { RS=" " } { if (thisres == $1) { print thisres } }' <<< "${availres[@]}")" ]; then
        read -r -d '' RESPBODY <<HERE
{ "error":"invalid path ($resource)" }
HERE
        echo "HTTP/1.1 404 Not Found"
        echo "Content-Length: ${#RESPBODY}"
        echo "Date: $(date -Ru)"
        echo ""
        echo "$RESPBODY"
else
        shortrec="$(sed 's/^\/stats[\/]*//g' <<< "$resource")"
        [[ -z "$shortrec" ]] && shortrec="all"

        read -r -d '' JSONDATA <<HERE
{
$(gen$shortrec)
}
HERE
        echo "HTTP/1.1 200 OK"
        echo "Content-Length: ${#JSONDATA}"
        echo "Date: $(date -Ru)"
        echo ""
        echo "$JSONDATA"
fi
