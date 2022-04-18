#!/bin/bash

TAG_NAME="2.2.2"

sql=$(cat <<EOF
{
  "tag_name": "v$TAG_NAME",
  "name": "v$TAG_NAME",
  "body": "$(cat release-notes.md)"
}
EOF
)

echo $sql