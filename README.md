# docker-sensu
Dockerization of the Sensu monitoring tool. Capable of running the client, server, and enterprise edition software. In order to use the enterprise edition you will need a subscription with Sensu.

Support for the client tool is in progress, I'm not sure what has to be exposed to the container for proper reporting.

# Installation
Pull the image from Dockerhub: `docker pull zeagler/docker-sensu`
Or build the image: `docker build -t docker-sensu .`

# Execution
To run a standalone server installation like the one described in the Sensu documentation: 
```
docker run -d \
  -e "MODE=STANDALONE" \
  -p 3000:3000 \
  -p 4567:4567 \
  -p 5671:5671 \
  -p 6379:6379 \
  -p 15672:15672 \
  -v /docker-sensu/default-config:/etc/sensu \
  zeagler/docker-sensu
```

# Configuration
The directory `/etc/sensu` holds all of the configuration, the included folder `default-config` has the minimum configuration as found in the Sensu documentation. As this is the folder that holds auth/checks/alerts/basically everything, it is advised that you mount your own configuration files to the directory.

There are options in place that can be set to enable other configurations. Such as client-only, HA, distributed, and enterprise edition. You can enable these by passing environment variables when starting the docker container.

`-e "RABBIT_PSWD=secret"` change the default RabbitMQ password in standalone mode  
`-e "SE_USER=xx"` and `-e "SE_PASS=xx"` when both of these are set enterprise edition is used

`-e "MODE=xx"`  
`CLIENT` the default mode, run sensu-client or sensu-enterprise  
`STANDALONE` enable standalone server mode  
`DISTRIBUTED"` coming-soon enable distributed server mode, ensure that the `/etc/sensu` config files are correct  
`HA` coming-soon enable HA server mode  
