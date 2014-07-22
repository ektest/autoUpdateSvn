SVNAutoUpdateScript
===================

svnUpdate.sh
===================

* Update a Subversion working copy
* Script also clears smarty cache
* Run it manually
* Good for lower environments (Prod unless you want to run update automatically)


svnUpdateClean.sh
===================

* Update a Subversion working copy
* Revert out local modifiactions
* Clear smarty cache
* Runs every 5 mins (Change it to 10 mins if you want! See the crontab settings below)
* Safe for lower environments (Stage, Test and development)

NOTE: This script destroys all local mods - run it with caution!


*Crontab Settings*
* #Below == Specific settings for svnUpdateClean.sh and it should be in the crontab.
* #CONTENT_TYPE="text/plain; charset=utf-8"
* */5 * * * * /bin/bash ~/your_main_folder/cron/svnUpdateClean.sh env-name ~/your_main_folder
* #  env-name is a "lock dir suffix" to lock the files
* #  ~/your_main_folder is a framework base dir where your project is stored
