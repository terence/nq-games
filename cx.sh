#!/bin/bash
#================================================================
# LOCAL Command-line Assistant - cx.sh
# - this script is run on local
# - DO NOT COPY TO REMOTE
# Bugs
# - cater for ESC key input - tough & don't bother
# Version 2.0
# - extract variables to vars.sh
# - capy base scripts from default
# - added second param to history log
#================================================================
clear
source ./vars.sh

echo =============================================================
echo Hi $USER@$HOSTNAME. You are in a .ssh/remote/$REMOTE directory.
echo What do you want to do?
for t in ${SITES[@]};
do
  echo "ARRAY $t"
done
echo -------------------------------------------------------------
echo GET ACCESS
echo 00 : CONNECT: to $REMOTE
echo 01 : RSYNC: my-plugin to Nikniq remote
echo 02 : RSYNC: Copy rm.sh to remote
echo 03 : SETUP BACKUP: Copy bk.sh to remote 
echo 04 : ANSIBLE: Scan 
echo ----------------------------------------------
echo SETUP REMOTE SYSTEM
echo 07 : Update REMOTE to latest packages 
echo 10 : SCAN Hosts with Ansible
echo 11 : CONNECT: hduser
echo 12 : xx
echo 13 : xx 
echo ----------------------------------------------
echo REMOTE COMMANDS - via rm.sh
echo 80 : RM CMD01: Run CMD1
echo ----------------------------------------------
echo BACKUP COMMANDS - via bk.sh
echo 90 : SETUP BACKUP CAPABILITY: Transfer backup script bk.sh from local to remote
echo 91 : Backup remote database and files
echo 99 : LOCAL FILE UPDATE and SECURITY SCRUB: checks ssh keys permissions
echo qq : Exit [Quit]
echo Enter [Selection] to continue
echo =============================================================
# Command line selection
if [ -n "$1" ]; then
  SELECTION=$1
else 
  read  -n 2 SELECTION
fi
if [ -n "$2" ]; then
  PARAM2=$2
else
  read  -n  PARAM2
fi
echo Your selection is : $SELECTION.
echo Your parameter is : $PARAM2. 


case "$SELECTION" in
# Note variable is quoted.

  "00" )
  echo ===========================================================
  echo CONNECT: user@hostname
  echo 
  echo ===========================================================
  echo CONNECT: to $REMOTE
  $APP_SSH $REMOTE
  echo Completed $SELECTION
  echo "Connect to remote" > tmpfile && cat ./log/history.log >> tmpfile && mv tmpfile ./log/history.log
  ;;


  "01" )
  echo ===========================================================
  echo GAIN ACCESS: Copy ssh settings from local to remote
  echo 
  echo ===========================================================
  $APP_SSH $REMOTE 'if [ -d ~/.ssh ]; then echo remote SSH directory exists; else echo Creating remote SSH directory; mkdir ~/.ssh/; fi'
  echo Copy authorized keys to remote
  $APP_SCP ~/.ssh/remote/$PROJECT/shell/authorized_keys  $REMOTE:~/.ssh/authorized_keys
  echo Copy known_hosts to remote
  $APP_SCP ~/.ssh/remote/$PROJECT/shell/known_hosts  $REMOTE:~/.ssh/known_hosts

  echo SECURITY: Set 700 to .ssh directory
  $APP_SSH $REMOTE 'if [ -d ~/.ssh ]; then chmod 700 ~/.ssh; fi'
  echo SECURITY: Set 600 to any private keys on remote
  $APP_SSH $REMOTE 'if [ -e ~/.ssh/id* ]; then chmod 600 ~/.ssh/id*; fi'
  echo SECURITY: Set 644 to any public keys on remote
  $APP_SSH $REMOTE 'if [ -d ~/.ssh/id*.pub ]; then chmod 644 ~/.ssh/id*.pub; fi'
  echo SECURITY: Set 600 to authorized_keys on remote. Mandatory for transparent sshing
  $APP_SSH $REMOTE 'if [ -e ~/.ssh/authorized_keys ];then chmod 600 ~/.ssh/authorized_keys;  fi'

  echo ===========================================================
  echo .vimrc, .alias .bashrc .bash_logout transfered
  echo ===========================================================
  $APP_SCP ~/.ssh/remote/$PROJECT/shell/.vimrc $REMOTE:~/.vimrc
  $APP_SCP ~/.ssh/remote/$PROJECT/shell/.alias $REMOTE:~/.alias
  $APP_SCP ~/.ssh/remote/$PROJECT/shell/.bashrc $REMOTE:~/.bashrc
  $APP_SCP ~/.ssh/remote/$PROJECT/shell/.bash_logout $REMOTE:~/.bash_logout

  echo ===========================================================
  echo .bash_profile updated
  echo ===========================================================
  $APP_SSH $REMOTE 'echo "source ~/.alias" >> ~/.bash_profile'
#  $APP_SSH $REMOTE 'echo "alias ll=/'ls -alh/'" >> ~/.bash_profile'
#  $APP_SSH $REMOTE 'echo "alias cl=\'clear; ls -alh\'" >> ~/.bash_profile'
#  $APP_SSH $REMOTE 'echo "PS1=/'[\u@\h:\w] $ /'" >> ~/.bash_profile'
  echo Completed $SELECTION
  echo "GAIN ACCESS: Copy ssh settings from local to remote" > tmpfile && cat ./log/history.log >> tmpfile && mv tmpfile ./log/history.log
  ;;


  "02" )
  echo ===========================================================
  echo GAIN CONTROL: Copy rm.sh to remote
  echo
  echo ===========================================================
  $APP_SSH $REMOTE 'if [ -d ~/'$PROJECT'/source ]; then echo remote SOURCE directory exists; else echo Creating remote SOURCE directory; mkdir ~/'$PROJECT'/source/; fi'
  $APP_SCP ~/.ssh/remote/$PROJECT/rm.sh  $REMOTE:~/.ssh/rm.sh
  $APP_SCP ~/.ssh/remote/$PROJECT/vars.sh  $REMOTE:~/.ssh/vars.sh
  echo SECURITY: Set 754 to rm.sh on remote. Enables execution
  $APP_SSH $REMOTE 'if [ -e ~/.ssh/rm.sh ];then chmod 754 ~/.ssh/rm.sh;  fi'
  echo Completed $SELECTION rm.sh to remote
  echo "GAIN CONTROL: Copy rm.sh to remote" > tmpfile && cat ./log/history.log >> tmpfile && mv tmpfile ./log/history.log
  ;;


  "03" )
  echo ===========================================================
  echo BACKUP CAPABILITY: Copy backup script bk.sh from local to remote
	echo
  echo ===========================================================
  $APP_SSH $REMOTE -p $REMOTE_PORT 'if [ -d ~/www/$PROJECT/backup ]; then echo remote BACKUP directory exists; else echo Creating remote BACKUP directory; mkdir ~/www/'$PROJECT'/backup/; fi'
  $APP_SCP -P $REMOTE_PORT ~/.ssh/remote/$PROJECT/bk.sh  $REMOTE:~/www/$PROJECT/bk.sh
  $APP_SCP -P $REMOTE_PORT ~/.ssh/remote/$PROJECT/vars.sh  $REMOTE:~/www/$PROJECT/vars.sh
  $APP_SSH $REMOTE -p $REMOTE_PORT 'if [ -d ~/www/'$PROJECT'/backup ]; then chmod 700 ~/www/'$PROJECT'/backup; fi'
  $APP_SSH $REMOTE -p $REMOTE_PORT 'if [ -e ~/www/'$PROJECT'/bk.sh ]; then chmod 755 ~/www/'$PROJECT'/bk.sh; fi'
  echo Completed $SELECTION bk.sh to remote
  echo "BACKUP CAPABILITY: Copy backup script bk.sh from local to remote" > tmpfile && cat ./log/history.log >> tmpfile && mv tmpfile ./log/history.log
  ;;


  "04" )
  echo ===========================================================
  echo ANSIBLE: Scan
  echo
  echo ===========================================================
  $APP_ANSIBLE -u $ANSIBLE_USER -i $ANSIBLE_INVENTORY $ANSIBLE_CLUSTER -m setup -v
  echo Completed $SELECTION Ansible Scan
  ;;


  "05" )
  echo ===========================================================
  echo MONITOR: Remote Top
  echo 
  echo ===========================================================
  $APP_SSH -t $REMOTE 'top'
  echo Completed $SELECTION Remote TOP
  ;;


  "06" )
  echo ===========================================================
  echo TERMINATE ACCESS: Delete remote ssh directory
  echo - delete all remote ssh settings
  echo 
  echo ===========================================================
  $APP_SSH $REMOTE 'cd ~/.ssh/ && rm *'
  echo Completed $SELECTION : Terminate remote ssh settings
  ;;


  "07" )
  echo ===========================================================
  echo UPDATE Remote
  echo - update remote with latest package cache
  echo 
  echo ===========================================================
  $APP_SSH $REMOTE 'date && sudo apt-get update' | tee /dev/tty >> $LOG_OUTPUT
  echo Completed $SELECTION : Update Remote apt-get update cache
  ;;

  "08" )
  echo ===========================================================
  echo INSTALL Python
  echo - install python on remote
  echo 
  echo ===========================================================
  $APP_SSH $REMOTE 'date && sudo apt-cache show python' | tee /dev/tty >> $LOG_OUTPUT
  $APP_SSH $REMOTE 'date && sudo apt-cache show python3' | tee /dev/tty >> $LOG_OUTPUT
#  $APP_SSH $REMOTE 'date && sudo apt-get update' | tee /dev/tty > ./log/remote.out
  echo Completed $SELECTION : Install Python
  ;;


  "09" )
  echo ===========================================================
  echo INSTALL Ansible
  echo - installs python and ansible on remote
  echo 
  echo ===========================================================
#  $APP_SSH $REMOTE 'date && sudo apt-cache show ansible' | tee /dev/tty >> $LOG_OUTPUT
  $APP_SSH $REMOTE 'date && sudo apt-get install ansible' | tee /dev/tty >> $LOG_OUTPUT
  echo Completed $SELECTION : Install Python
  ;;
  

  "10" )
  echo ===========================================================
  echo SCAN Hosts with Ansible
  echo - using ansible
  echo
  echo ===========================================================
  $APP_ANSIBLE -u $ANSIBLE_USER -i $ANSIBLE_INVENTORY $ANSIBLE_CLUSTER -m setup -v
  ;;


  "11" )
  echo ===========================================================
  echo CONNECT: hduser
  echo - using ansible
  echo
  echo ===========================================================
  echo CONNECT: to hduser@$REMOTE_HOST
  $APP_SSH hduser@$REMOTE_HOST
  echo Completed $SELECTION: CONNECT hduser
  ;;




  "80" )
  echo ===========================================================
  echo REMOTE Shell
  echo - using rm.sh
  echo
  echo ===========================================================
  $APP_SSH $REMOTE '~/.ssh/rm.sh 01'
  ;;


  "88" )
  echo SSH-agent add all keys
  # suspect that ssh-agent auto add keys if they match
  ;;


  "91" )
  echo ===========================================================
  echo BACKUP: Backup database and files.
  echo - PARAM2 - enters description
  echo ===========================================================
  $APP_SSH -t $REMOTE_USER@$REMOTE_HOST '~/'$PROJECT"/bk.sh 01 '"$PARAM2"'"
  $APP_SSH -t $REMOTE_USER@$REMOTE_HOST '~/'$PROJECT"/bk.sh 02 '"$PARAM2"'"
  echo "Backup database and files" > tmpfile && cat ./log/history.log >> tmpfile && mv tmpfile ./log/history.log
  ;;


  "99" )
  echo ===========================================================
  echo LOCAL FILE UPDATE and SECURITY SCRUB
  echo
  echo ===========================================================
  $TEMP_PWD pwd
  if [ -d "shell" ]; then
    echo "shell dir exists"
  else
    mkdir shell
  fi
  if [ -d "log" ]; then
    echo "log dir exists"
  else
    mkdir log
    touch ./log/history.log
  fi
  if [ -d "files" ]; then
    echo "log dir exists"
  else
    mkdir files
  fi
  cp $LOCAL_SCRIPTS_DEFAULT/README.txt .
  cp $LOCAL_SCRIPTS_DEFAULT/shell/.alias ./shell
  cp $LOCAL_SCRIPTS_DEFAULT/shell/.vimrc ./shell
  cp $LOCAL_SCRIPTS_DEFAULT/shell/.bashrc ./shell
  cp $LOCAL_SCRIPTS_DEFAULT/shell/.bash_logout ./shell
  cp $LOCAL_SCRIPTS_DEFAULT/shell/authorized_keys ./shell
  cp $LOCAL_SCRIPTS_DEFAULT/shell/known_hosts ./shell
  cp $LOCAL_SCRIPTS_DEFAULT/rm.sh .
  cp $LOCAL_SCRIPTS_DEFAULT/bk.sh .
  cp $LOCAL_SCRIPTS_DEFAULT/mm.sh .

  # Cleanup
  rm .*
  rm authorized_keys
  rm known_hosts

  # TODO: Disable execution for bk.sh, rm.sh and vars.sh. Only enabled on remote
  
  # chmod 700 ~/.ssh directory
  # chmod 600 authorized_keys (if it exists on client machines)
  # chmod 600 id_*
  # chmod 644 *.pub
  cd ~/.ssh/
  chmod 700 ~/.ssh
  chmod 600 id*
  chmod 644 id*.pub
  if [ -e ~/.ssh/authorized_keys ];then
    chmod 600 ~/.ssh/authorized_keys
  fi
  cd $TEMP_PWD
  echo "Refreshed files from Default" > tmpfile && cat ./log/history.log >> tmpfile && mv tmpfile ./log/history.log
  ;;


  # Attempt to cater for ESC
  "\x1B" )
  echo ESC1
  exit 0
  ;;


  # Attempt to cater for ESC
  "^[" )
  echo ESC2
  exit 0
  ;;


  "qq" )
  echo Quit
  exit 0
  ;;


   * )
   # Default option.	  
   # Empty input (hitting RETURN) fits here, too.
   echo
   echo "Not a recognized option."
  ;;

esac

