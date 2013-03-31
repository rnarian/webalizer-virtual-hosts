#!/bin/bash

##
# Shell Script to process multiple hosts 
# individually using the 'webalizer' command
# 



# Exclude the following hosts
excludes=('marianfriedmann.de' 'munin')

# Public HTML Folders
public_html='/var/www/{VHOST}/public_html/webalizer'

# Logs
logs='/var/log/apache2/{VHOST}-access.log'

###

echo ""

logs_before=$(echo $logs | sed 's/{VHOST.*//g')
logs_after=$(echo $logs | sed 's/.*VHOST}//g')
logs_regex_before=$(echo $logs_before | sed "s%/%\\\/%g")
logs_regex_after=$(echo $logs_after | sed "s%/%\\\/%g")

# quick hack to make the log files "for eachable"
function logsArr { echo $logs | sed 's/{VHOST}/\*/g';}

for i in $(logsArr); do
  echo "processing" $i "..."
  vhost=$(echo $i | sed "s/$logs_regex_before//g" | sed "s/$logs_regex_after//g")
	for e in ${excludes[@]}; do
    if [ "$vhost" == "$e" ]; then
        exclude="true";
    fi
  done
  # check if excludeCurrent is set
  if [ -n "${exclude+x}" ]; then
    echo "--> vhost "\"$vhost\"" is in excludes array"
    echo "--> stop"
  else
    echo "--> go on"
    public_html_output=$(echo $public_html | sed "s/{VHOST}/$vhost/g")
    logs_input=$(echo $logs | sed "s/{VHOST}/$vhost/g")
    echo "webalizer -n $vhost -o $public_html_output $logs_input"
  fi
  unset exclude
  unset vhost
  echo ""
done