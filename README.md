# cron-backup
A bash script you use with crontab to dump your database and push to Bitbucket.

+ Update `cron-backup.sh` with settings (db credentials, paths)
  ```bash
  # Set remote url to bitbucket or github.
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
  ```

+ Change permissions:
  ````bash
  $ chmod ug+x ./cron-backup.sh
  ````

+ Add to `crontab`:
  ```bash
  $ crontab -e
  ```
  ```bash
  # Backup db and uploaded files
  # at 5 a.m every day with:
  0 5 * * * /path/to/cron-backup.sh
  ```
Save!
