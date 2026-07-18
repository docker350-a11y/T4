#!/bin/bash

echo "========================================="
echo "             user management             "
echo "========================================="
# Check if script is running as root
LOG_FILE="./LOG_FILE.txt"
if [[ $EUID -ne 0 ]]; then
    echo "❌ Please run this script as root."
    echo "Example:"
    echo "sudo ./script.sh"
    exit 1


fi


# 1. user se input lene ke liye

read -p "enter your user name: " uname

# 2. check user enter something or not
if [[ -z "$uname" ]]; then
	echo "enter something"
	exit 1
fi
# 3.. check spaces between user name
if [[ "$uname" == *" "* ]]; then
		echo "don't use spaces in user's name"
		exit 1
fi
# 4. check user does not add symbols or characters
if [[ ! "$uname" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
	echo "do not use special symbols"
	exit 1
fi
	
echo "it's such a Nice name $uname"
# 5. check karne ke liye user exit karta h kya nhi 

if grep -q "^$uname:" /etc/passwd; then
	echo "yes ,user exists!"
else
	read -p "no user does not exist!.. you want to create new user yes/no " ans

# 6. user ne input khali to nhi choda	
	if [[ -z "$ans" ]]; then
		echo "enter something"
		exit 1
	fi

    	if [[ "${ans,,}" == "yes" || "${ans,,}" == "y" ]]; then
    		read -p  "enter your new username: " unsame
    		if [[ -z "$unsame" ]]; then
    		    echo "Enter username dude!!!!"
    		    exit 1
    		fi
    		if [[ "$unsame" == *" "* ]]; then
    				echo "don't use spaces in user's name"
    				exit 1
    		fi
    		if [[ ! "$unsame" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
    			echo "do not use special symbols"
    			exit 1
    		fi
   			if useradd "$unsame"; then
	   			echo "user: "$unsame" creating............... "
	   		if grep -q "^$unsame:" /etc/passwd; then
	   			echo "$(date '+%Y-%m-%d %H:%M:%S') | User Created | Username: $unsame | Created By: $USER" >> "$LOG_FILE"
	   			echo "yes ,use create successfully"

	   		else
	   		    echo "❌ Failed to create user!"
	   		    exit 1
	   		fi
	   		fi

	   	elif [[ "${ans,,}" == "no" || "${ans,,}" == "n" ]]; then
	   		echo "ok thanks!!"
		else 
			echo "have a good day!!!"
		fi
		
fi
echo "========================================="
echo "                   end                   "
echo "========================================="

