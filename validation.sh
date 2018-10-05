#/usr/bin/bash
# get virtual name, status, total connections per partition 
#8-27-18 updates to functions
# focus on state change for virtuals, pools, nodes.
# added connection diffs also for current connections
# create list function
createList() {
action=$1
type=$2
comparepartitons=$3
#echo "comparepartitons: $comparepartitons"
if [ "$action" == "check" ]; then
    filename="newDevice_$type.txt"
    devicename="newDevice"
elif [ "$action" == "create" ]; then
    filename="oldDevice_$type.txt"
    devicename="oldDevice"
fi

if [ "$type" == "virtual" ]; then
    filter="ltm virtual"
    confilter="clientside.cur-conns"
elif [ "$type" == "pool" ]; then
    filter="ltm pool"
    confilter="cur-sessions"
elif [ "$type" == "node" ]; then
    filter="ltm node"
    confilter="cur-sessions"
fi


# set variables
date=`date '+%Y_%m_%d'`
confile="connections_${filename}"
statusfile="status_${filename}"
echo "As of $date" > $statusfile
echo "As of $date" > $confile
echo "Creating $filter list for $devicename"
#
#
# get list of partitions
# partitions=`tmsh list auth partition | grep partition | grep -v Common | cut -f3 -d' '`
#
# Get list of all items
inventory=$(nice -n 19 tmsh -q -c 'cd /; list ltm '$type'  recursive one-line' | grep "$filter" | awk '{print $3}')
#
#
# loop through and log to text file oldDevice.txt
#per virtual
#get name
#get status
#get connections
#
#
while read -r line; do
#reading lines of $inventory and checking number of occurrences per entry
    name=$line
    if [ "$optionverbose" == 1 ]; then
        echo "working on ${line[@]}"
    fi
    status=$(nice -n 19 tmsh -q -c 'cd /; show ltm '$type' '$line' field-fmt' | grep status.availability-state | awk '{print $2}')
    connections=$(nice -n 19 tmsh -q -c 'cd /; show ltm '$type' '$line' field-fmt' | grep $confilter | awk '{print $2}')
    if [ "$comparepartitons" == 0 ]; then
        line="$(cut -d'/' -f 2,3 <<<"$line")"
        #echo "mod line: ${line[@]}"
    fi
    printf "name:$line,currentconnections:$connections\n" >> $confile
    printf "name:$line,status:$status\n" >> $statusfile
        done <<< "$inventory"
#
#use name to lookup the status, use the name to lookup the total connections
#print $item /r/n $status /r/n $connections >> oldDevice.txt
items=$(wc -l < $statusfile)
items=$(let items=items-1)
message="$type List created in $statusfile, $items"
echo $message
#
#
# uncomment me to check current connections needs rework
#echo "removing objects with zero connections"
basename=${confile%.txt}
grep -v "currentconnections:0" $confile > $basename'_removed_zero.txt'
echo "$type zero connections list created in ${basename}_removed_zero.txt "
#virtual zero connections list created in connections_oldDevice_virtual'_removed_zero.txt'
}
#
#
# check list function
checkList() {
type=$1
if [ "$type" == "virtual" ]; then
    filter="ltm virtual"
    filename="newDevice_$type.txt"
elif [ "$type" == "pool" ]; then
    filter="ltm pool"
    filename="newDevice_$type.txt"
elif [ "$type" == "node" ]; then
    filter="ltm node"
    filename="newDevice_$type.txt"
fi

    echo "generating status_${filename}"
    createList check $type;
}
#
# deletes the lists created by the script
deleteList() {
type=$1
if [ "$type" == "virtual" ]; then
    filter="ltm virtual"
elif [ "$type" == "pool" ]; then
    filter="ltm pool"
elif [ "$type" == "node" ]; then
    filter="ltm node"
fi
 
    ls -h
    echo "removing status_oldDevice_$type.txt"
    rm -f status_oldDevice_$type.txt
    rm -f connections_oldDevice_$type.txt
    rm -f rm -f connections_oldDevice_"$type"_removed_zero.txt
    echo "removing newDevice_$type.txt"
    rm -f status_newDevice_$type.txt
    rm -f connections_newDevice_$type.txt
    rm -f rm -f connections_newDevice_"$type"_removed_zero.txt
    ls -h
}
# opens the diff file by type
viewDiff() {
type=$1
    less diff-$type-$date.txt
}
# creates the diffs by type
createDiff() {
type=$1
date=`date '+%Y_%m_%d'`
#
echo "Diff status_newDevice_${type}.txt and status_oldDevice_${type}.txt"
echo "sending results to: diff-${type}-status-${date}.txt"
#diff /var/tmp/$partition-virtual-address-state-precheck.txt /var/tmp/$partition-virtual-address-state-postcheck.txt > /var/tmp/$partition-virtual-address-state-diffs-$datestamp.txt
diff status_oldDevice_$type.txt status_newDevice_$type.txt > diff-${type}-status-${date}.txt
echo "Diff connections_newDevice_${type}.txt and connections_oldDevice_${type}.txt"
echo "sending results to: diff-${type}-connections-${date}.txt"
diff connections_oldDevice_$type.txt connections_newDevice_${type}.txt > diff-${type}-connections-${date}.txt
echo "Diff removed zero connections_oldDevice_${type}_removed_zero.txt and connections_newDevice_${type}_removed_zero.txt"
echo "sending results to: diff-$type-connections-removed_zero-${date}.txt"
diff connections_oldDevice_${type}_removed_zero.txt connections_newDevice_${type}_removed_zero.txt > diff-$type-connections-removed_zero-${date}.txt
#ls -h
}
#
# create the log tar ball for support per: https://support.f5.com/csp/article/K9360
#
createLogs() {
date=`date '+%Y_%m_%d'`
echo "creating log tarball in $PWD "
tar -czpf logfiles_$date.tar.gz /var/log/*
ls -lh $PWD/logfiles_$date.tar.gz
}

#
# sub menu verbose
#
# sub menu  verbose options
#
optionverbose=0
option_verbose () {
    optionverbose=$1
    echo "verbose: $optionverbose"
}

#
sub_menu_verbose(){
while :
do
echo "Verbose output, Default is off:"
echo -e "\t(1) off"
echo -e "\t(2) on"
echo -e "\t(e) Back"
echo -n "Please enter your choice:"
read c
case $c in
    "1"|"off")
    # verbose off
    option_verbose 0
    break 
    ;;
    "2"|"on")
    # verbose on
    option_verbose 1
    break
    ;;
    "e"|"E"|"q")
    break
    ;;
        *)
        echo "invalid answer, please try again"
        ;;
esac
done
}
#
# sub menu paritions
#
#
# sub menu  paritions options
optionpartitions=1
option_partitions () {
    optionpartitions=$1
    echo "paritions: $optionpartitions"
}
#
#
#
sub_menu_partitions(){
while :
do
echo "Compare Objects by partiton Default is on:"
echo -e "\t(1) partitons on"
echo -e "\t(2) partitons off"
echo -e "\t(e) Back"
echo -n "Please enter your choice:"
read c
case $c in
    "1")
    # partitons on
    option_partitions 1
    break 
    ;;
    "2")
    # partitons off
    option_partitions 0
    break
    ;;
    "e"|"E"|"q")
    break
    ;;
        *)
        echo "invalid answer, please try again"
        ;;
esac
done
}
#
# menu
#
main_menu(){
echo "Please select an Action:"
echo -e "\t(1) Create list All Old Device" 
echo -e "\t(2) Create list virtuals Old Device" 
echo -e "\t(3) Create list pools Old Device" 
echo -e "\t(4) Create list nodes Old Device" 
echo -e "\t(5) Check list All New Device" 
echo -e "\t(6) Check list virtuals New Device"
echo -e "\t(7) Check list pools New Device"
echo -e "\t(8) Check list nodes New Device"
echo -e "\t(9) Delete all lists"
echo -e "\t(10) Create diff"
echo -e "\t(11) Tar logs for F5 Support"
echo -e "\t(12) View current logs"
echo -e "\t(q) Quit"
echo -n "Please enter your choice:"
read opt
while :
do
    case $opt in
        "1"|"Create list All Old Device")
            sub_menu_partitions
            part="$optionpartitions"
            sub_menu_verbose
            createList create virtual $part ;
            createList create pool $part;
            createList create node $part;
            break
            ;;
        "2"|"Create list virtuals Old Device")
            sub_menu_partitions
            part="$optionpartitions"
            sub_menu_verbose
            createList create virtual $part;
            break
            ;;
        "3"|"Create list pools Old Device")
            sub_menu_partitions
            part="$optionpartitions"
            sub_menu_verbose
            createList create pool $part;
            break
            ;;
        "4"|"Create list nodes Old Device")
            sub_menu_partitions
            part="$optionpartitions"
            sub_menu_verbose
            createList create node $part;
            break
            ;;
        "5"|"Check list All New Device")
            sub_menu_partitions
            part="$optionpartitions"
            sub_menu_verbose
            createList check virtual $part;
            createList check pool $part;
            createList check node $part;
            break
            ;;
        "6"|"Check list virtuals New Device")
            sub_menu_partitions
            part="$optionpartitions"
            sub_menu_verbose
            createList check virtual $part;
            break
            ;;
        "7"|"Check list pools New Device")
            sub_menu_partitions
            part="$optionpartitions"
            sub_menu_verbose
            createList check pool $part;
            break
            ;;
        "8"|"Check list nodes New Device")
            sub_menu_partitions
            part="$optionpartitions"
            sub_menu_verbose
            createList check node $part;        
            break
            ;;
        "9"|"Delete all lists")
            deleteList virtual $part;
            deleteList pool $part;
            deleteList node $part;
            break
            ;;
        "10"|"Create diff")
            createDiff virtual $part;
            createDiff pool $part;
            createDiff node $part;
            ls -h
            break
            ;;
        "11"|"logs")
            createLogs
            break
            ;;
        "12"|"tailf logs")
            echo "Please select a Module:"
            echo -e "\t(1) ltm" 
            echo -e "\t(2) apm" 
            echo -e "\t(3) asm"
            echo -e "\t(4) gtm"
            echo -e "\t(5) afm"
            echo -n "Module input:"
            read module
            case $module in
            "1"|"ltm")
                mod="ltm"
                ;;
            "2"|"apm")
                mod="apm"
                ;;
            "3"|"asm")
                mod="asm"
                ;;
            "4"|"gtm")
                mod="gtm"
                ;;
            "5"|"afm")
                mod="afm"
                ;;
            *)
                echo "Not found in this list"
                ;;
            esac
            echo "Do want to filter the output?:"
            echo -e "\t(1) yes" 
            echo -e "\t(2) no"
            read filter
            case $filter in
            "1"|"yes")
                grep="yes"
                ;;
            "2"|"no")
                grep="no"
                ;;
            esac
            if [ "$grep" == "yes" ]; then
                #echo "grep was $grep"
                echo "Please set a grep filter:"
                echo -n "grep -i <your input>:"
                read grepfilter
                if [ "$grepfilter" == "" ]; then
                grepfilter="'[ A-Za-z0-9]*'"
                fi
                tailf /var/log/$mod | grep -i $grepfilter
            fi
            tailf /var/log/$mod
            ;;
        "13"|"Quit"|"q"|"Q"|"e")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
}

#
# start menu
#
main_menu
