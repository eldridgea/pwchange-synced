#!/bin/bash

#====================================================================================
#   ENSURE SCRIPT IS NOT RUNNNG AS ROOT
if [[ $(/usr/bin/id -u) -eq 0 ]]; then
    echo "This is running as root. Please ruin from the acount of the user you want to have the passwords synced for."
    exit
fi

#====================================================================================
#    STARTS SUDO SESSION IF NECESSARY
printf "Starting sudo session if necessary\n"
sudo -v

#====================================================================================
#    SETS VARS FROM SHADOWFILE
shadow_info=$(sudo getent shadow $USER)
salt=$(echo $shadow_info | cut -d '$' -f 3)
algorithm=$(echo $shadow_info | cut -d '$' -f 2)
shadowfile_hash="$"$(echo $shadow_info | cut -d '$' -f 2- | cut -d ':' -f 1)

#====================================================================================
#    GETS OLD PASSWORD FROM INPUT, HASH IT, VALIDATE IT AGAINST SHADOWFILE
printf "Old Password:"
read -s old_password
user_input_old_password=$(echo $old_password | openssl passwd -$algorithm -salt $salt -stdin)
if [ "$user_input_old_password" = "$shadowfile_hash" ]; then
  :
else
  printf "\nThat doesn't match your current user password\n"
  exit
fi

#====================================================================================
#    GETS NEW PASSWORD FROM USER INPUT
printf "\nNew Password:"
read -s new_password
printf "\nNew Password Again:"
read -s new_password_again
## If user doens't enter identical new passwords exit
if [ "$new_password" = "$new_password_again" ]; then
  :
else
  printf "New Passwords don't match\n"
  exit
fi

#====================================================================================
#    ATTEMPTS TO SET LUKS PASSWORD
luks_device=$(lsblk -fs -p -o NAME,FSTYPE,NAME | grep -m 1 crypto_LUKS | rev | cut -d ' ' -f1 | rev)
printf '\nAttempting to set LUKS password. (This step may take about 30 seconds). . .'
printf '%s\n' "$old_password" "$new_password" "$new_password" | sudo cryptsetup luksChangeKey $luks_device >/dev/null 2>&1 &
pid=$(echo $!)
wait $pid
return_code=$(echo $?)
if [ "$return_code" == 0 ]
then
	printf "\nSet LUKS Password Successfully!"
else
	printf "\nCouldn't change LUKS password, ensure user and LUKS password start out the same\n"
	exit
fi

#====================================================================================
#    ATTEMPTS TO SET USER PASSWORD AND EXITS
printf '\nAttempting to set user password . . .'
printf '%s\n' "$old_password" "$new_password" "$new_password" | passwd >/dev/null 2>&1 &
pid=$(echo $!)
wait $pid
return_code=$(echo $?)
if [ "$return_code" == 0 ]
then
        printf "\nSet User Password Successfully!"
else
        printf "\nCouldn't change user password, not sure why\n"
        exit
fi
printf "\n"
