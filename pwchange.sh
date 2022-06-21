#!/bin/bash
source spinny.sh

if [[ $(/usr/bin/id -u) -eq 0 ]]; then
    echo "running as root. Please ruin from the acount of the user you want to have the passwords synced for"
    exit
fi

printf "Starting sudo session if necessary\n"
sudo -v
# Set some variables automatically
salt=$(sudo cat /etc/shadow | grep $USER | cut -d '$' -f 3)
algorithm=$(sudo cat /etc/shadow | grep $USER | cut -d '$' -f 2)
shadowfile_hash="$"$(sudo cat /etc/shadow | grep $USER | cut -d '$' -f 2- | cut -d ':' -f 1)


#printf "\nSalt:"$salt
#printf "\nAlgorithm:"$algorithm
#printf "\nHash:"$shadowfile_hash"\n"



#########Get Old password#################
#echo "Going to update your main and boot password at the same time"
printf "Old Password:"
read -s old_password

## hsah user inputted password
user_input_old_password=$(echo $old_password | openssl passwd -$algorithm -salt $salt -stdin)
#printf "\n user_input_old_password: $user_input_old_password"
#printf "\nshadowfile_hash         : $shadowfile_hash\n"


## Check to see if the user-entered $old_password matches the password in shadowfile
if [ "$user_input_old_password" = "$shadowfile_hash" ]; then
  # printf "Password match!\n"
  :
else
  printf "\nThat doesn't match your current user password\n"
  exit
fi


###########Get New password 

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
################################################

luks_device=$(lsblk -fs -p -o NAME,FSTYPE,NAME | egrep -m 1 crypto_LUKS | rev | cut -d ' ' -f1 | rev)
#printf "\n$luks_device\n"
#printf "\nold$old_password"
#printf "\nnew$new_password"

#printf '%s\n' "$old_pass" "$new_pass" "$new_pass" | cryptsetup luksChangeKey $luks_device
#echo -e "$old_pass""\n""$new_pass""\n""$new_pass" | cryptsetup luksChangeKey $luks_device

#echo -e "$old_pass\n$new_pass\n$new_pass" | cryptsetup luksChangeKey $luks_device


#while true; do
printf '\nAttempting to set LUKS password . . .'
spinny::start
printf '%s\n' "$old_password" "$new_password" "$new_password" | sudo cryptsetup luksChangeKey $luks_device >/dev/null 2>&1 &
pid=$(echo $!)
wait $pid
return_code=$(echo $?)
#echo $?
#echo $a
#break
#done
#printf $return_code
spinny::stop
if [ "$return_code" == 0 ]
then
	printf "\nSet LUKS Password Successfully!"
else
	printf "\nCouldn't change LUKS password, ensure user and LUKS password start out the same\n"
	exit
fi

####### using passwd
#while true; do
printf '\nAttempting to set user password . . .'
spinny::start
printf '%s\n' "$old_password" "$new_password" "$new_password" | passwd >/dev/null 2>&1 &
pid=$(echo $!)
wait $pid
return_code=$(echo $?)
spinny::stop
if [ "$return_code" == 0 ]
then
        printf "\nSet User Password Successfully!"
else
        printf "\nCouldn't change user password, not sure why\n"
        exit
fi
printf "\n"
