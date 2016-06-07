#!/bin/bash

# Enterprise Edition
if [ "$SE_USER" != "" ] && [ "$SE_PASS" != "" ]; then

  # Install enterprise edition
  if wget -q http://$SE_USER:$SE_PASS@enterprise.sensuapp.com/apt/pubkey.gpg -O- | sudo apt-key add -; then
    echo "deb     http://$SE_USER:$SE_PASS@enterprise.sensuapp.com/apt sensu-enterprise main" | tee /etc/apt/sources.list.d/sensu-enterprise.list
    apt-get update
    dpkg -P uchiwa
    apt-get -o Dpkg::Options::="--force-confold" install --force-yes -y \
      sensu-enterprise \
      sensu-enterprise-dashboard
  else
    echo "Error authorizing enterprise account"
    exit 1
  fi
    
  if [ "$MODE" = "STANDALONE" ]; then
    /etc/init.d/redis-server start
    /etc/init.d/rabbitmq-server start

    if [ -z $RABBIT_PSWD ]; then
      RABBIT_PSWD=secret
    fi

    rabbitmqctl add_vhost /sensu
    rabbitmqctl add_user sensu $RABBIT_PSWD
    rabbitmqctl set_permissions -p /sensu sensu ".*" ".*" ".*"
    
    /etc/init.d/sensu-client start
    /etc/init.d/sensu-enterprise start
    /etc/init.d/sensu-enterprise-dashboard start
    /opt/sensu-enterprise-dashboard/bin/dashboard -c /etc/sensu/dashboard.json -d /etc/sensu/dashboard.d -p /opt/sensu-enterprise-dashboard/src/public
  elif [ "$MODE" = "DISTRIBUTED" ]; then
    echo "coming soon"
    exit 1
  elif [ "$MODE" = "HA" ]; then
    echo "coming soon"
    exit 1
  else
    /usr/bin/sensu-enterprise 
  fi



# Standard Edition
elif [ "$MODE" = "STANDALONE" ]; then
  /etc/init.d/redis-server start
  /etc/init.d/rabbitmq-server start

  if [ -z $RABBIT_PSWD ]; then
    RABBIT_PSWD=secret
  fi

  rabbitmqctl add_vhost /sensu
  rabbitmqctl add_user sensu $RABBIT_PSWD
  rabbitmqctl set_permissions -p /sensu sensu ".*" ".*" ".*"
  
  /etc/init.d/sensu-client start
  /etc/init.d/sensu-server start
  /etc/init.d/sensu-api start
  /opt/uchiwa/bin/uchiwa -c /etc/sensu/uchiwa.json -d /etc/sensu/dashboard.d -p /opt/uchiwa/src/public
elif [ "$MODE" = "DISTRIBUTED" ]; then
    echo "coming soon"
    exit 1
elif [ "$MODE" = "HA" ]; then
    echo "coming soon"
    exit 1
else
  /opt/sensu/bin/sensu-client -c /etc/sensu/conf.d/client.json -d /etc/sensu/conf.d -e /etc/sensu/extensions
fi