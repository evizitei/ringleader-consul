## Ringleader

(perhaps also known as "docker-register + arbitrary config info in ruby", special thanks
to https://github.com/jwilder/docker-register)

Ringleader sets up a container running [docker-gen][https://github.com/jwilder/docker-gen].  It then watches
for containers with the right metadata and sends their exposed configuration data
through to consul, which can be queried by other services.

#### THIS IS A PORT OF /evizitei/ringleader for consul.

### Usage

on startup,
ringleader will start up an internal consul instance exposed on 8500 to
make config information available to consul clients in other containers without
having to run a seperate consul container.  Startup ringleader like this:

```bash
$ docker run -p 8500:8500 -v /var/run/docker.sock:/var/run/docker.sock evizitei/ringleader-consul
```

The port flag is necessary for letting consul clients talk to the process in this container. If
using in conjunction with https://github.com/jwilder/nginx-proxy (which I recommend),
then you'll want to pass -e VIRTUAL_HOST=consul.docker or something to make sure other clients
don't have to find the docker host IP or anything, and that would look like this:

```bash
$ docker run -e VIRTUAL_HOST=consul.docker -e VIRTUAL_PORT=8500 -p 8500:8500 -v /var/run/docker.sock:/var/run/docker.sock evizitei/ringleader-consul
```

Make sure to use VIRTUAL_PORT.  Because the container exposes multiple ports, it
can make nginx-proxy output a bad config file and break *all* your routing when
it tries to restart.

Now ringleader is running and watching for any containers with labels (https://docs.docker.com/userguide/labels-custom-metadata/) that look like this:

```Dockerfile
LABEL consul_conf_key="base_key"
LABEL consul_conf_data="{\"key1\"=\"value1\",\"key2\"=\"value2\"}"
```

The 'consul_conf_key' is the url bucket in consul into which the data will be placed,
and the 'consul_conf_data' is a json hash of the data you want the container to expose.
For example, if you launched some application container with the above labels in
them, ringleader would talk to consul and you'd end up with this:

```bash
$> curl http://consul-host:4001/v1/kv/base_key?recurse
[{
  "CreateIndex":97,
  "ModifyIndex":97,
  "Key":"base_key/key1",
  "Flags":0,
  "Value":"dmFsdWUx"
},{
  "CreateIndex":98,
  "ModifyIndex":98,
  "Key":"base_key/key2",
  "Flags":0,
  "Value":"dmFsdWUy"}]
```

(note the values are base64 encoded)

And now other containers can ask for configuration information relevant to the "base_key" app.

Naturally, once the container with that metadata is no longer running, ringleader
will delete that directory from consul so other apps don't expect to be able to
talk to a service that's no longer running.
