SVNAutoUpdateScript
===================

svnUpdate.sh
===================

* Automatically update a Subversion working copy
* Automatically clear smarty cache
* Run it manually
* Good for lower environments (Prod unless you want to run everything automatically)


svnUpdateClean.sh
===================

* Automatically update a Subversion working copy
* Automatically reverts local modifiactions
* Automatically clear smarty cache
* Automatically runs every 5 mins (Change it to 10 mins if you want! See the crontab settings below)
* Good for lower environments (Stage, Test and development)

NOTE: This script destroys all local mods - run it with caution!


*Crontab Settings*
* #Below == Specific settings for svnUpdateClean.sh and it should be in the crontab.
* #CONTENT_TYPE="text/plain; charset=utf-8"
* */5 * * * * /bin/bash ~/your_main_folder/cron/svnUpdateClean.sh env-name ~/your_main_folder
* #  env-name is a "lock dir suffix" to lock the files
* #  ~/your_main_folder is a framework base dir where your project is stored
