# postfix
Postfix project for docker 

## First time configuration
Build the docker image:

>docker build -t yourimage.

When starting the image for the first time, some additional parameters are
required to configure the Postfix server:

```
docker run 
        -h postfix \
        -e LOCALNETWORK="<your-local-network-ip>/<subnetlen>" \
        -e OTHERNETWORK="<other-network>/<subnetlen>" \
        -e ROOT_PASSWORD="<your-root-password>" \
        -e RELAYHOST="<your-relay-host>" \
        -e RELAYUSER="<user-to-sign-in-on-your-relay-host>" \
        -e RELAYUSERPASSWORD="<password-of-user-to-sign-in-on-your-relay-host>" \
        --name postfix \
        --net=<yournet> \
        -p 25:25 \
        -d yourimage
```

