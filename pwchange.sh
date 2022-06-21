#!/bin/bash

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Not running as root"
    exit
fi

# Set some variables automatically
salt=$(sudo cat /etc/shadow | grep eldridgea | cut -d '$' -f 3)
algorithm=$(sudo cat /etc/shadow | grep eldridgea | cut -d '$' -f 2)
shadowfile_hash="$"$(sudo cat /etc/shadow | grep eldridgea | cut -d '$' -f 2- | cut -d ':' -f 1)


#printf "\nSalt:"$salt
#printf "\nAlgorithm:"$algorithm
#printf "\nHash:"$shadowfile_hash"\n"



#########Get Old password#################
echo "Going to update your main and boot password at the same time"
printf "\nOld Password:"
read -s old_password

##verify password
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


###########Get New password and validate if it's entered the same way twice

printf "\nNew Password:"
read -s new_password
printf "\nNew Password Again:"
read -s new_password_again
printf "\n"

## If user doens't enter identical new passwords exit
if [ "$new_password" = "$new_password_again" ]; then
  :
else
  printf "New Passwords don't match\n"
  exit
fi
################################################

luks_device=$(lsblk -fs -p -o NAME,FSTYPE,NAME | egrep -m 1 crypto_LUKS | rev | cut -d ' ' -f1 | rev)
printf "\n$luks_device\n"
