# Simple exim relay in Docker
Dockerized exim for sending mails to smarthost(s)

## What is this?

I wanted a simple and small Docker container with exim in it to relay mail to a smarthost or multiple smarthosts.
Applications can submit their mail to this and take advantage of exim's queueing capabilites.
Also the container should be restartable without losing spooled mails.

## How to use it?

```bash
$ docker build -t docker-exim .
$ docker run -it --rm \
    --init \
    --name docker-exim \
    -p "25:2525" \
    -v eximspool:/var/spool/exim \
    -e SMARTHOSTS="smtp.example.com" \
    docker-exim
```
This should build and start the container ready for SMTP relaying to the smarthost list.

### Specify permitted subnets

If you don't specify `RELAY_FROM_HOSTS` then only localhost (127.0.0.1, ::1) can relay mail.
Here's an example for allowing a host in the subnet 192.0.2.0/24 to relay to the smarthost:

```bash
$ docker run -it --rm \
    --init \
    --name docker-exim \
    -p "25:2525" \
    -v eximspool:/var/spool/exim \
    -e RELAY_FROM_HOSTS="<; 127.0.0.1 ; ::1 ; 192.0.2.0/24" \
    -e SMARTHOSTS="smtp.example.com" \
    docker-exim
```

**Note:** The syntax is explained [here](https://www.exim.org/exim-html-current/doc/html/spec_html/ch-domain_host_address_and_local_part_lists.html#SECTnamedlists) or below.

### Direct delivery using MX DNS lookups

If you don't want to use smart hosts, just omit the env var `SMARTHOSTS` like this:

```bash
$ docker run -it --rm \
    --init \
    --name docker-exim \
    -p "25:2525" \
    -v eximspool:/var/spool/exim \
    docker-exim
```

### Modify EHLO/HELO hostname sent

Some servers block messages from servers sending EHLO data which doesn't resolve in DNS. You can override this setting:

```bash
$ docker run -it --rm \
    --init \
    --name docker-exim \
    -p "25:2525" \
    -v eximspool:/var/spool/exim \
    -e HELO_DATA="mail.example.com"
    docker-exim
```

**Note:** the `$primary_hostname` var in exim is still the result of `hostname()`.

### About multiple smarthosts

The smarthost list should follow the exim specs about host lists.
For example if you want `mx1.example.com` and `mx2.example.com` to both act as smart hosts (exim tries the first, then the second etc.), specify the `SMARTHOSTS` env var as follows:

```bash
-e SMARTHOSTS="mx1.example.com : mx2.example.com"
```

or with ports other than 25:

```bash
-e SMARTHOSTS="mx1.example.com::1025 : mx2.example.com::8025"  # yes, double colon (::)
```

See also: https://www.exim.org/exim-html-current/doc/html/spec_html/ch-the_manualroute_router.html

### Security

I wanted a container where exim does not use its root privileges since it doesn't need to deliver locally. Here exim runs as user `exim` and the `harden.sh` script should remove a lot of possible attack vectors :)

### Size

I tried to keep the Docker image small when building it.

## Notes

* The `/var/log/exim/main` log is redirected to `stdout`. This way it can be logged by Docker log drivers.
* I don't know why yet but exim doesn't exit when the container wants to stop. Running the container with `--init` helps.

## Thanks to

* @jumanjiman for the [gists](https://gist.github.com/jumanjiman/da6935986c1d1d2a7451)
* @adegtyarev for the [inspiration](https://github.com/adegtyarev/docker-exim)
