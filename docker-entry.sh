#!/bin/bash

if [[ "$1" == "test" ]]; then
  mkdir "$HOME"/.kerbi
  echo "auth-type: in-cluster" > "$HOME"/.kerbi/config.yaml
  cat "$HOME"/.kerbi/config.yaml
  bundle exec rspec spec/main/mixer_spec.rb -fd
#  bundle exec rspec -fd
#  rspec_status=$(echo $?)
  rspec_status="1"
  echo "Exit RSpec with $rspec_status"
  exit "$rspec_status"
elif [[ "$1" == "publish" ]]; then
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
