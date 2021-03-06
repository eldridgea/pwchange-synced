# pwchange-synced
### Password change tool which updates both LUKS and user passwords simultaneously

| :exclamation:   not production ready in any way whatsoever :exclamation: |
|-------------------------------------------------------------|

Use this instead of the normal `passwd` tool going forward and it should update your LUKS and user passwords simultaneously. That way you only have one password for both your boot and login.

It's a normal(ish) password change tool that attempts to reset the LUKS disk encryption and user password at the same time to ensure they stay in sync. This is intended mostly for devices that have only one user or a primary user and want that user's password to both unlock the LUKS disk encryption and be that user's login password.

Run this tool as the user you want to have the synced passwords

This tool expects passwords to already be the same so if they're not, make them the same manually before using this tool.

I only have my machine to test on but this works on my Dell XPS 2022 with Ubuntu 20.04. I _believe_ this should work on any Linux system with one bootable system that's Linux, uses systemd, and encrypts the disk with LUKS. This is the default for most modern distros including Ubuntu so if you used the installation wizard when installing or configuring your OS this will probably work for you.


### Notes

Variables I would want to verify if attempting to use this on another system include

1. The script can pull the salt, hash, and algorithm correctly from the shadow file.

1. The `openssl` component behaves as expected to validate the user password

1. The script can correctly identify the correct disk device


