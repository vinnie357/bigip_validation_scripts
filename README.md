# bigip_validation_scripts
Bash scripts for validation of bigip-configuration during migration work

These scripts are meant to help validate pre and post migration configuration state.
the focus is on the virtual server objects, their status and total connections.

## running
```
bash validation.sh
```
## Options
### 1. Create list All Old Device
Creates an output file for current connection counts as well as object status for all object types. 
*ex: virtual server* 
virtual state,connections
pool state,connections
node state,connections
### 2. Create list virtuals Old Device
Creates an output file for current connection counts as well as object status for virtual servers. 
### 3. Create list pools Old Device
Creates an output file for current connection counts as well as object status for pools. 
### 4. Create list nodes Old Device
Creates an output file for current connection counts as well as object status for nodes. 
### 5. Check list All New Device
Creates an output file for current connection counts as well as object status for all object types. 
*ex: virtual server* 
virtual state,connections
pool state,connections
node state,connections
### 6. Check list virtuals New Device
Creates an output file for current connection counts as well as object status for virtual servers. 
### 7. Check list pools New Device
Creates an output file for current connection counts as well as object status for pools. 
### 8. Check list nodes New Device
Creates an output file for current connection counts as well as object status for nodes. 
### 9. Delete all lists
Attempts to delete all the lists created
### 10. Create diff
If you have old and new device outputs, this will create a diff output for each object type based on object name type status and current connection counts
### 11. Tar logs for F5 Support
Creates a tarball of /var/log/* per: https://support.f5.com/csp/article/K9360
### 12. View current logs
accepts a module, and does a tail with the follow command on your device
ex: tailf /var/log/{yourchoice} | grep -i {user input}
### 13. Quit
Exits the script menu

## Outputs created by script
```
### old device ###
status_oldDevice_virtual.txt
status_oldDevice_pool.txt
status_oldDevice_node.txt
connections_oldDevice_virtual.txt
connections_oldDevice_virtual_removed_zero.txt
connections_oldDevice_pool.txt
connections_oldDevice_pool_removed_zero.txt
connections_oldDevice_node.txt
connections_oldDevice_node_removed_zero.txt

#### new device ###
status_newDevice_virtual.txt
status_newDevice_pool.txt
status_newDevice_node.txt
connections_newDevice_virtual.txt
connections_newDevice_virtual_removed_zero.txt
connections_newDevice_pool.txt
connections_newDevice_pool_removed_zero.txt 
connections_newDevice_node.txt
connections_newDevice_node_removed_zero.txt

#### diffs ###
diff-virtual-status-2018_08_27.txt
diff-pool-status-2018_08_27.txt
diff-node-status-2018_08_27.txt
diff-virtual-connections-2018_08_27.txt
diff-pool-connections-2018_08_27.txt
diff-node-connections-2018_08_27.txt
diff-virtual-connections-removed_zero-2018_08_27.txt
diff-pool-connections-removed_zero-2018_08_27.txt
diff-node-connections-removed_zero-2018_08_27.txt

#### logs ###
logfiles_2018_09_16.tar.gz
```
## ToDo ##
1.  Connectivity Stats
- needs: menu, logic, diffs
  - objects:
    - interface
      - show net interface field-fmt | grep 'name\|status\|counters.drops\|counters.errors\|counters.pkts-*'
      - tmsh show net interface field-fmt | grep 'status\|name' | awk '{print $2}'
    - trunk
      - show net interface field-fmt |  grep 'status\|name'
    - vlans
      - show net vlan field-fmt | grep 'status\|ifname'
      - tmsh show net vlan field-fmt | grep 'status\|ifname' | awk '{print $2}'
