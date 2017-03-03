#!/bin/bash
# Scriptacular - gitinit.sh
# Initialize a directory with git, stage and commit existing files

FILE_TYPE="."
INITIAL_COMMIT_MESSAGE="Initial commit"

# Set remote url to bitbucket or git. 
# I've added username and password because I won't be there
# to tell crontab but you should probably figure out
# a more secure way to pass your credentials to git.
UPSTREAM="https://username:password@bitbucket.org/username/my-backup-repo.git"

# Database credentials
user="########"
password="***********"
host="localhost"
db_name="mysql_db"

# Where to keep backup files
# Make sure writable and readable
backup_path="/var/path/to/backup/folder"

# Log - For debugging if script fails in crontab
# log_path="/var/www/path/to/backuplog.log"

# redirect stdout/stderr to a file
# exec &> $log_path

# Other options
date=$(date +"%d-%b-%Y")
currtime=$(date +"%Y-%m-%d %H:%M:%S")

# Set default file permissions
# User - u+rwx (read, write, execute)
# Group - g-rwx (none)
# Others - o-rwx (none)
umask 077

# Switch to backup path
cd $backup_path
echo "Attempting backup: $currtime"

# Initialize git
if [ -d ".git" ]; then
  echo "This directory has already been initialized with git."
else
  git init
  if (( $? )); then
      echo "Unable to initialize your directory"
      exit 1
  fi
  git add "$FILE_TYPE"
  if (( $? )); then
      echo "Unable to stage files"
      exit 1
  fi
	git remote add bitbucket "$UPSTREAM"
	if (( $? )); then
			echo "Unable to add remote url (bitbucket)"
			exit 1
	fi

  touch README.md
  touch .gitignore
  echo " ----- "
  echo "The directory was initialized and an initial commit was performed with the files matching the pattern '$FILE_TYPE'"
fi
git pull bitbucket master
if (( $? )); then
    echo "Unable to pull from remote url (bitbucket)"
    # exit 1
fi

# Dump database into SQL file
mysqldump --user=$user --password=$password --host=$host $db_name > $backup_path/$db_name-$date.sql

# Compress / tar files uploaded or generated in user seesions
# (profile pictures or product pictures e.t.c) [ uncomment next line ------ > ]
# tar cvfz $backup_path/files-$date.tar.gz /var/www/path/to/files

# Delete files older than 30 days
find $backup_path/* -mtime +30 -exec rm {} \;

# Commit new changes
git add "$FILE_TYPE"
if (( $? )); then
		echo "Unable to stage files"
		exit 1
fi
git commit -m "Cron backup commit - $date"
if (( $? )); then
		echo "Unable to create the initial commit"
		exit 1
fi
git push bitbucket master
if (( $? )); then
		echo "Unable to push latest commit to Bitbucket"
		exit 1
fi
echo " ----- "
echo "Backup was successful. Good bye."

exit 0
