#/usr/bin/bash
# get virtual name, status, total connections per partition 
#
#
# create list function
createList() {
action=$1
if [ "$action" == "check" ]; then
    filename="output1.txt"
elif [ "$action" == "create" ]; then
    filename="output.txt"
fi
echo "Creating list for $filename"
# set variables
date=`date '+%Y_%m_%d'`
# get list of partitions
# partitions=`tmsh list auth partition | grep partition | grep -v Common | cut -f3 -d' '`
#
# Get list of all virtuals
inventory=$(tmsh -q -c 'cd /; list ltm virtual  recursive one-line' | grep 'ltm virtual' | awk '{print $3}')
#
#
# loop through and log to text file output.txt
#per virtual
#get name
#get status
#get connections
echo "As of $date" > $filename
while read -r line; do
#reading lines of $inventory and checking number of occurrences per entry
    name=$line
    echo "working on ${line[@]}"
    status=$(tmsh -q -c 'cd /; show ltm virtual '$line' field-fmt' | grep status.availability-state | awk '{print $2}')
    connections=$(tmsh -q -c 'cd /; show ltm virtual '$line' field-fmt' | grep clientside.tot-conns | awk '{print $2}')
    #printf "name:$line\nstatus:$status\ntotalconnections:$connections\n" >> $filename
    printf "name:$line,status:$status,totalconnections:$connections\n" >> $filename
        done <<< "$inventory"
#
#use name to lookup the status, use the name to lookup the total connections
#print $item /r/n $status /r/n $connections >> output.txt
message="List created in $filename"
echo $message
#
#
echo "removing objects with zero connections"
grep -v "totalconnections:0" $filename > $filename'_removed_zero.txt'
}
#
#
# check list function
checkList() {
    echo "generating output1.txt"
    createList check
    ls -h
    echo "Diff output1.txt and output.txt"
    echo "sending results to diff-$date.txt"
    #diff /var/tmp/$partition-virtual-address-state-precheck.txt /var/tmp/$partition-virtual-address-state-postcheck.txt > /var/tmp/$partition-virtual-address-state-diffs-$datestamp.txt
    diff output.txt output1.txt > diff-$date.txt
    ls -h
}
#
#
deleteList() {
    ls -h
    echo "removing output.txt"
    rm -f output.txt
    echo "removing output1.txt"
    rm -f output1.txt
    ls -h
}

viewDiff() {
    less diff-$date.txt
}
#
# menu
#
PS3='Please select an action: '
options=("Create list" "Check list" "Delete list" "View diff" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Create list")
            createList create;
            ;;
        "Check list")
            checkList check;
            ;;
        "Delete list")
            deleteList
            ;;
        "View diff")
            viewDiff
            ;;
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done


