#/usr/bin/bash
# get virtual name, status, total connections per partition 
#8-27-18 updates to functions
# focus on state change for virtuals, pools, nodes.
# added connection diffs also for current connections
# create list function
createList() {
action=$1
type=$2
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
    echo "working on ${line[@]}"
    status=$(tmsh -q -c 'cd /; show ltm '$type' '$line' field-fmt' | grep status.availability-state | awk '{print $2}')
    connections=$(tmsh -q -c 'cd /; show ltm '$type' '$line' field-fmt' | grep $confilter | awk '{print $2}')
    confile="connections_$filename"
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
echo "removing objects with zero connections"
basename=${confile%.txt}
grep -v "currentconnections:0" $confile > $basename'_removed_zero.txt'
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
# menu
#
PS3='Please select an action: '
#options=("Create list" "Check list" "Delete list" "View diff" "Quit")
options=("Create list All Old Device" "Create list virtuals Old Device" "Create list pools Old Device" "Create list nodes Old Device" "Check list All New Device" "Check list virtuals New Device" "Check list pools New Device" "Check list nodes New Device" "Delete all lists" "Create diff" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Create list All Old Device")
            createList create virtual;
            createList create pool;
            createList create node;
            ;;
        "Create list virtuals Old Device")
            createList create virtual;
            ;;
        "Create list pools Old Device")
            createList create pool;
            ;;
        "Create list nodes Old Device")
            createList create node;
            ;;
        "Check list All New Device")
            createList check virtual;
            createList check pool;
            createList check node;
            ;;
        "Check list virtuals New Device")
            createList check virtual;
            ;;
        "Check list pools New Device")
            createList check pool;
            ;;
        "Check list nodes New Device")
            createList check node;
            ;;
        "Delete all lists")
            deleteList virtual;
            deleteList pool;
            deleteList node;
            ;;
        "Create diff")
            createDiff virtual;
            createDiff pool;
            createDiff node;
            ;;
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
