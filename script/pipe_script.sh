#!/bin/sh

#replace [HOMEPATH] with actual path

export HOME=[HOMEPATH]
export HPATH=$HOME
export GEM_HOME=$HPATH/ruby/gems
export GEM_PATH=$GEM_HOME:/lib64/ruby/gems/2.2.2
export GEM_CACHE=$GEM_HOME/cache
export PATH=$HPATH/ruby/bin:$PATH
export PATH=$HPATH/ruby/gems/bin:$PATH
export PATH=$HPATH/ruby/gems:$PATH
export BUNDLE_PATH=$HOME/mail-forwarder/vendor/bundle

for foo in `cat /dev/stdin`
do
  cd [HOMEPATH]/mail-forwarder/script
  bundle exec $foo | ruby [HOMEPATH]/mail-forwarder/script/run_mail_forwarder.rb
done
