#!/bin/bash

#
# Webalizer Virtual Hosts
#
# Shell Script to process multiple hosts individually 
# using the 'webalizer' command.
# 
# In order to make this Script work, we need to generate 
# seperate 'access.log's for our vhosts. We assume that 
# the name of the vhosts occur in our public_html folder 
# as well as in our logfile.
# 


# Configuration

# Exclude the following hosts (use spaces as seperator 
# e.g. 'example.com' 'ws2.com')
excludes=('munin')

# Logs
logs='/var/log/apache2/{VHOST}-access.log'

# Public HTML Folders
public_html='/var/www/{VHOST}/public_html'

# Webalizer output folder (within each vhosts public_html)
webalizer_output='webalizer'

# Debugging (Uncomment to see console output)
debug='true'

#

logs_before=$(echo $logs | sed 's/{VHOST.*//g')
logs_after=$(echo $logs | sed 's/.*VHOST}//g')
logs_regex_before=$(echo $logs_before | sed "s%/%\\\/%g")
logs_regex_after=$(echo $logs_after | sed "s%/%\\\/%g")

# echo function to suppress console output in production
function e { if [ -n "${debug+x}" ]; then echo $1; fi; }

# quick hack to make the '$logs' for eachable
logsArr=$(echo $logs | sed 's/{VHOST}/\*/g')

# For each element in our list of logfiles
for i in $logsArr; do
  e ""
  e "processing $i ..."

  # Regex to get vhost name
  vhost=$(echo $i | sed "s/$logs_regex_before//g" | sed "s/$logs_regex_after//g")

  # Set '$exclude' if '$vhost' matches excludes list element
	for o in ${excludes[@]}; do
    if [ "$vhost" == "$o" ]; then
        exclude="true";
    fi
  done

  # check if '$exclude' is set (means the vhost is in our exclude list and we 
  # shouldn't process the logfile any further)
  if [ -n "${exclude+x}" ]; then
    e "--> vhost \"$vhost\" is in excludes array"
    e "--> stop"
  else
    e "--> go on"
    public_html_output=$(echo $public_html | sed "s/{VHOST}/$vhost/g")
    public_html_output=$(echo $public_html_output/$webalizer_output)
    logs_input=$(echo $logs | sed "s/{VHOST}/$vhost/g")
    webalizer -n $vhost -o $public_html_output $logs_input
  fi

  unset exclude
  unset vhost
done