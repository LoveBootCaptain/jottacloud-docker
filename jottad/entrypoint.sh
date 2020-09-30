#!/bin/bash

# set timezone
rm /etc/localtime
ln -s /usr/share/zoneinfo/"$LOCALTIME" /etc/localtime

rm -f /etc/jottad/config.ini
echo "ListenAddr=$LISTENADDR" >> /usr/local/jottad/config.ini
ln -s /usr/local/jottad/config.ini /etc/jottad/config.ini

# make sure we are running the latest version of jotta-cli
apt-get update
apt-get install jotta-cli

# set the jottad user and group id
usermod -u "$PUID" jottad
usermod --gid "$PGID" jottad
usermod -a -G jottad jottad

# start the service
/etc/init.d/jottad start

# wait for service to fully start
sleep 5

if [[ "$(jotta-cli status)" =~ ERROR.* ]]; then

  echo "First time login"

  # Login user
  /usr/bin/expect -c "
  set timeout 20
  spawn jotta-cli login
  expect \"accept license (yes/no): \" {send \"yes\n\"}
  expect \"Personal login token: \" {send \"$JOTTA_TOKEN\n\"}
  expect \"Devicename*: \" {send \"$JOTTA_DEVICE\n\"}
  expect eof
  "

else

  echo "User is logged in"

fi

  # load ignore file
  if [ -f /etc/jottad/ignorefile ]; then
    echo "loading ignore file"
    jotta-cli ignores set /etc/jottad/ignorefile
  fi

  # set scan interval
  echo "Setting scan interval"
  jotta-cli config set scaninterval "$JOTTA_SCANINTERVAL"

# put tail in the foreground, so docker does not quit
tail -f /dev/null

exec "$@"
