# PWCHANGESYNC

## Not productiuon ready in any way whatsoever

Normal(ish) password change tool that attempts to reset the disk encryption and user password at the same time to make sure they stay in sync. This is intended mostly for devices that have only one user or a primary user and want that user's password to both unlock the LUKS disk encryption and just be the normal user password.

Run this tool as the user you want to have the synced passwords

This tool expects passwords to already be the same so if they're not make them the same manually before using this tool.