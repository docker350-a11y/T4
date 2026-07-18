#!/bin/bash

#root authentication(privilege)
if [[ $EUID -ne 0 ]]; then
	echo "this script required root privilege......"
	echo "Example: sudo {script name}"
	exit 1
fi

#disk usage
disk (){
	d_usage=$(df -h / | awk 'NR==2 {print int($5)}')
	echo "                   "
	echo "                   "
	echo "=========== DISK INFO ============"
	echo "DISK usage is: ${d_usage}"
	if [[ "$d_usage" -gt 80 ]]; then
	echo "           warning disk fill above 80% || current: ${d_usage}%"

	else 
	echo "           chill bro your disk sapec ki below 80% || current: ${d_usage}%"
	fi
}

#ram usage
ram (){
	echo "                   "
	echo "                   "
	echo "========= RAM INFO ========= " 
	echo "RAM info: "
	echo "           "$(free -h | awk 'NR==1 {print $1}') $(free -h | awk 'NR==2 {print $2}')
	echo "           "$(free -h | awk 'NR==1 {print $2}')  $( free -h | awk ' NR==2 { print $3}')
	ram_used=$(free -h | awk 'NR==2  {print int(($3/$2)*100)}')
	echo "RAM_Usage: ${ram_used}%"
	if [[ "$ram_used" -gt 75 ]];then
	echo "           Ram usage is above 75% || current: ${ram_used}"

	else 
	echo "           chill bro ram is below or equal of 75% || current: ${ram_used}"
	fi
}


# cpu
cpu (){
	echo "                   "
	echo "                   "
	echo "========= CPU USAGE ========= "
	echo "CPU uasge"
	cpu_usage=$(top -bn1 | awk 'NR==3 {print int(100- $8)}')
	#echo "CPU usage is: "$cpu_usage
	if [[ "$cpu_usage" -gt 90 ]]; then
	echo "           warning cpu usage is above 90% || current: ${cpu_usage}%"

	else 
	echo "           chill bro CPU usage is below 90% || current: ${cpu_usage}%"
	fi
}

overall (){
	echo "                   "
	echo "                   "
	echo "========= OVER ALL ========= "
	if [[ "$cpu_usage" -gt 90 ||  "$ram_used" -gt 75 || "$d_usage" -gt 80 ]]; then
		echo "over all system health is not good BRO!!!!!"

	else
		echo "chill BRO system overall condition is good !!!!"
	fi
		echo "                   "
	echo "                   "
}


log_file=system_health.txt
{
	echo "======================================"
	echo "          SYSTEM HEALTH               "
	echo "report generaet ON $(date '+%Y-%m-%d :%H-%M-%S')"
	echo "======================================"
	
	disk
	ram
	cpu
	overall
} | tee -a "$log_file"
