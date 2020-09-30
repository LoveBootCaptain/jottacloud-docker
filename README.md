# jottacloud-docker
Docker image for personal use

**This is the basis for an Unraid docker template for the community applications.**

The matching xml and some more documentation will follow the next days.


````
docker build -t beta .
    && docker run
    -p 0.0.0.0:14443:14443
    -v /data:/var/lib/jottad
    --env JOTTA_DEVICE=JottaSyncHost
    --env JOTTA_SCANINTERVAL=2h
    --env LOCALTIME=Europe/Berlin
    --env JOTTA_TOKEN=*****
    --env PUID=99
    --env PGID=100
    --env LISTENADDR=0.0.0.0
    --name jottacloud
    -h JottaSyncHost
beta
````

