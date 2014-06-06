#!/bin/bash

if [ ! -n "$AWS_ACCESS_KEY_ID" ]; then
  echo ' [!] Input AWS_ACCESS_KEY_ID is missing'
  exit 1
fi

if [ ! -n "$AWS_SECRET_ACCESS_KEY" ]; then
  echo ' [!] Input AWS_SECRET_ACCESS_KEY is missing'
  exit 1
fi

if [ ! -n "$S3_UPLOAD_LOCAL_PATH" ]; then
  echo ' [!] Input S3_UPLOAD_LOCAL_PATH is missing'
  exit 1
fi

if [ ! -n "$S3_UPLOAD_BUCKET" ]; then
  echo ' [!] Input S3_UPLOAD_BUCKET is missing'
  exit 1
fi


function print_and_do_command {
  echo "$ $@"
  $@
}


print_and_do_command brew install s3cmd
print_and_do_command s3cmd --version
printf %"s\n" '[default]' "access_key = $AWS_ACCESS_KEY_ID" "secret_key = $AWS_SECRET_ACCESS_KEY" > $HOME/.s3cfg

s3_url="s3://$S3_UPLOAD_BUCKET"
print_and_do_command s3cmd sync "$S3_UPLOAD_LOCAL_PATH" "$s3_url" --delete-removed

aclcmd='--acl-private'
if [ "$S3_ACL_CONTROL" == 'public-read' ]; then
  echo " (i) ACL 'public-read' specified!"
  aclcmd='--acl-public'
fi
s3cmd setacl "$s3_url" $aclcmd --recursive

rm $HOME/.s3cfg
