#!/bin/bash

cmd="svn update ${HOME}/your_main_folder/"
echo "${cmd}"
${cmd}

for i in  $( find ${HOME}/your_main_folder/cache_directory/ | grep '/smarty$' ) ; do
        cmd="sudo rm -rf $i"
        echo "${cmd}"
        ${cmd}
done
