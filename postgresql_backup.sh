#!/bin/bash

. ./postgresql_backup.config

mkdir --parents --verbose $BACKUP_DIR

for database in "${DATABASES[@]}"
  do
    echo "++ $database"

    mkdir --parents --verbose "$BACKUP_DIR/$database"
    cd $BACKUP_DIR/$database
    number=`ls -l $BACKUP_DIR/$database | grep -v ^l | wc -l`

    if [ $((number-1)) -gt $ROTATION_FILO_LENGTH ] ; then
      oldest_file_name=`find -type f -printf "%T+%p\n"  | sort | head -n 1 | cut -d '/' -f 2`
      echo "DELETING: " $oldest_file_name
      rm -f $oldest_file_name
    fi

    archive_name="$CURRENT_DATE""_backup."$database".gz"
    output_dir="$BACKUP_DIR/$database/$CURRENT_DATE.$database"
    `pg_dump -F d -b -c -C -j $JOBS_NUM -f $output_dir $database | gzip > "$archive_name"`
    echo "COMPRESSING $archive_name"
    echo "CLEANUP $output_dir"
    `rm -r -f $output_dir`
  done

echo "DONE"