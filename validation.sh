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
elif [ "$action" == "create" ]; then
    filename="oldDevice_$type.txt"
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

echo "Creating $filter list for $filename"
# set variables
date=`date '+%Y_%m_%d'`
# get list of partitions
# partitions=`tmsh list auth partition | grep partition | grep -v Common | cut -f3 -d' '`
#
# Get list of all items
inventory=$(tmsh -q -c 'cd /; list ltm '$type'  recursive one-line' | grep "$filter" | awk '{print $3}')
#
#
# loop through and log to text file oldDevice.txt
#per virtual
#get name
#get status
#get connections
echo "As of $date" > $filename
while read -r line; do
#reading lines of $inventory and checking number of occurrences per entry
    name=$line
    if [ "$optionverbose" == 1 ]; then
        echo "working on ${line[@]}"
    fi
    status=$(tmsh -q -c 'cd /; show ltm '$type' '$line' field-fmt' | grep status.availability-state | awk '{print $2}')
    connections=$(tmsh -q -c 'cd /; show ltm '$type' '$line' field-fmt' | grep $confilter | awk '{print $2}')
    confile="connections_$filename"
    if [ "$comparepartitons" == 0 ]; then
        line="$(cut -d'/' -f 2,3 <<<"$line")"
        #echo "mod line: ${line[@]}"
    fi
    printf "name:$line,currentconnections:$connections\n" >> $confile
    printf "name:$line,status:$status\n" >> $filename
        done <<< "$inventory"
#
#use name to lookup the status, use the name to lookup the total connections
#print $item /r/n $status /r/n $connections >> oldDevice.txt
items=$(wc -l < $filename)
items=$(let items=items-1)
message="$type List created in $filename, $items"
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

    echo "generating newDevice_'$type'.txt"
    createList check $type;
}
#
#
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
    echo "removing oldDevice_$type.txt"
    rm -f oldDevice_$type.txt
    rm -f connections_oldDevice_$type.txt
    rm -f rm -f connections_oldDevice_"$type"_removed_zero.txt
    echo "removing newDevice_$type.txt"
    rm -f newDevice_$type.txt
    rm -f connections_newDevice_$type.txt
    rm -f rm -f connections_newDevice_"$type"_removed_zero.txt
    ls -h
}

viewDiff() {
type=$1
    less diff-$type-$date.txt
}
createDiff() {
type=$1
date=`date '+%Y_%m_%d'`
#
echo "Diff newDevice_'$type'.txt and oldDevice_'$type'.txt"
echo "sending results to diff-$date.txt"
#diff /var/tmp/$partition-virtual-address-state-precheck.txt /var/tmp/$partition-virtual-address-state-postcheck.txt > /var/tmp/$partition-virtual-address-state-diffs-$datestamp.txt
diff oldDevice_$type.txt newDevice_$type.txt > diff-$type-$date.txt
echo "Diff connections"
diff connections_oldDevice_$type.txt connections_newDevice_$type.txt > diff-connections-$type-$date.txt
ls -h
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
            sub_menu_partitions
            part="$optionpartitions"
            sub_menu_verbose
            deleteList virtual $part;
            deleteList pool $part;
            deleteList node $part;
            break
            ;;
        "10"|"Create diff")
            sub_menu_partitions
            part="$optionpartitions"
            sub_menu_verbose
            createDiff virtual $part;
            createDiff pool $part;
            createDiff node $part;
            break
            ;;
        "11"|"Quit"|"q"|"Q"|"e")
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
