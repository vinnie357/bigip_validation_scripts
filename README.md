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
### 11. Quit
Exits the script menu

## Outputs created by script
```
### old device ###
oldDevice_virtual.txt
oldDevice_pool.txt
oldDevice_node.txt
connections_oldDevice_virtual.txt
connections_oldDevice_virtual_removed_zero.txt
connections_oldDevice_pool.txt
connections_oldDevice_pool_removed_zero.txt
connections_oldDevice_node.txt
connections_oldDevice_node_removed_zero.txt

#### new device ###
newDevice_virtual.txt
newDevice_pool.txt
newDevice_node.txt
connections_newDevice_virtual.txt
connections_newDevice_virtual_removed_zero.txt
connections_newDevice_pool.txt
connections_newDevice_pool_removed_zero.txt 
connections_newDevice_node.txt
connections_newDevice_node_removed_zero.txt

#### diffs ###
diff-virtual-2018_08_27.txt
diff-pool-2018_08_27.txt
diff-node-2018_08_27.txt
diff-connections-virtual-2018_08_27.txt
diff-connections-pool-2018_08_27.txt
diff-connections-node-2018_08_27.txt
```

