#!/bin/sh
# Simple Mesh Watchdog
# 
# For OpenWRT, Created by Ilija Culap
# Some parts are copied from mesh11sd project

# Get mesh interfaces
getMeshIFs () {

	# Get list of all interfaces
	iflist=""
	all_ifcs=$(iw dev | awk -F "Interface " '$2>0{printf "%s " $2}')

	# Check if the interface is mesh type
	for iface in $all_ifcs; do
		iftype=$(iw dev $iface info 2> /dev/null | grep "type" | awk '{printf "%s", $2}')

		if [ ! -z "$iftype" ] && [ "$iftype" = "mesh" ]; then
			iflist="$iflist $iface"
		fi
	done

}

setParams () {

        # Cycle through all parameters
        while read usr_param; do
                if [ -n "$usr_param" ] && [ -z "$(echo "$usr_param" | grep "#")" ] && [ -n "$(echo "$usr_param" | grep "mesh_")" ]; then
                        
						# Get and compare it to current parameter
						if [ "$(iw dev $MESH_IFACE get mesh_param $(echo "$usr_param" | awk '{printf "%s", $1}') | awk '{printf "%s", $1}')" != "$(echo "$usr_param" | awk '{printf "%s", $2}')" ]; then
							# Set paramters
							iw dev $MESH_IFACE set mesh_param $usr_param

							# Log the change to system log
							logger -t "smwd" -p "daemon.info" "Setting: $usr_param on $MESH_IFACE"
						fi

                fi
        done < /etc/config/smwd

}

removePhantoms () {
	
	# Get all phantoms on mesh path list
	PHANTOMS=$(iw dev $MESH_IFACE mpath dump | sed -n -e "/\s00:00:00:00:00:00\s/s/\s.*$//p")
	
	# Remove Phantoms from mesh paths
	for mac_addr in $PHANTOMS; do
		iw dev $MESH_IFACE mpath del "$mac_addr"
		logger -t "smwd" -p "daemon.info" "Removing $mac_addr from mesh path list"
	done

}

# Log the start
logger -t "smwd" -p "daemon.info" "Starting!" 

while true; do

	# Get list of all mesh interfaces
	getMeshIFs
	
	# Go through all the interfaces
	for MESH_IFACE in $iflist; do
		
		# Check if mesh-iface is up
		if [ -n "$(iw dev $MESH_IFACE station dump | grep "ESTAB")" ]; then
		
			# If mesh-iface is up, set up mesh_params
			setParams

			# Check for phantoms
			removePhantoms

		else

			# If mesh-iface is still down
			logger -t "smwd" -p "daemon.err" "All interfaces are down, waiting 1 minute"
			sleep 60

		fi

		# Wait 10 seconds
		sleep 10

	done
done
