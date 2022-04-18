#!/bin/bash

if [[ "$1" == "test" ]]; then
  mkdir "$HOME"/.kerbi
  echo "{\"k8s-auth-type\": \"in-cluster\"}" > "$HOME"/.kerbi/config.json
  bundle exec rspec -fd
  rspec_status="$?"
  echo "Exit RSpec with $rspec_status"
  exit "$rspec_status"
elif [[ "$1" == "publish" ]]; then
  echo "USING API KEY $RUBYGEMS_API_KEY"
  echo ":rubygems_api_key: $RUBYGEMS_API_KEY" > /root/.gem/credentials
  chmod 0600 /root/.gem/credentials
  gem build kerbi.gemspec
  gem push $(ls | grep ".gem$"); exit 0
elif [[ "$1" == "sleep" ]]; then
  echo "Going to sleep..."
  while true; do sleep 30; done;
else
  echo Bad args "$@"
fi
