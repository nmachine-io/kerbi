ls | grep ".gem$" | xargs -d"\n" rm
gem build kerbi.gemspec
gem uninstall kerbi --no-executables
gem install $(ls | grep ".gem$")