# jewelcat: A fast, zero-config development server for OS X and Linux

jewelcat is a fork of `puma-dev`. It's a direct response to the large backlog of pull-requests on puma-dev.

## Highlights

* Easy startup and idle shutdown of rack/rails apps
* Easy access to the apps using the `.test` subdomain **(configurable)**

### Why not just use pow?

Pow doesn't support rack.hijack and thus not websockets and thus not actioncable. So for all those new Rails 5 apps, pow is a no-go. jewelcat fills that hole. jewelcat also goes one step further and provides zero-config https support to your development environment, as well as offering Linux support.

### Why not just use `puma-dev`?
`puma-dev`, while actively maintained, is *incredibly* slow to accept pull requests. jewelcat aims to fix that by being responsive to any incoming pull requests and issues.

## Install

*Note: Linux is currently broken, but only briefly.*

* Or download the latest release from https://bitbucket.org/bpollack/jewelcat/releases
* If you haven't run jewelcat before, run: `sudo jewelcat -setup` to configure some DNS settings that have to be done as root
* Run `jewelcat -install` to configure jewelcat to run in the background on ports 80 and 443 with the domain `.test`.

*NOTE:* if you had pow installed before in the system, please make sure to run
pow's uninstall script. Read more details in [the pow manual](http://pow.cx/manual.html#section_1.2). Likewise, if you had `puma-dev` installed, you'll need to uninstall that first as well.

#### .test domain

Install the [dev-tld-resolver](https://github.com/puma/dev-tld-resolver) to make domains resolve.

#### Port 80/443 binding

There are 2 options to allow jewelcat to listen on port 80 and 443.

1. `sudo setcap CAP_NET_BIND_SERVICE=+eip /path/to/jewelcat`
2. Use `authbind`.

You don't need to bind to port 80/443 to use jewelcat but obviously it makes using the `.test` domain much nicer.

There is a shortcut for binding to 80/443 by passing `-sysbind` which overrides `-http-port` and `-https-port`.

### Options

Run: `jewelcat -h`

You have the ability to configure most of the values that you'll use day-to-day.

### Setup (OS X only)

Run: `sudo jewelcat -setup`.

This configures the bits that require root access, which allows your user access to the `/etc/resolver` directory.

### Background Install/Upgrading for port 80 access (OS X only)

If you want jewelcat to run in the background while you're logged in and on a common port, then you'll need to install it.

Run `jewelcat -install`.

If you wish to have `jewelcat` use a port other than 80, pass it via the `-install-port`, for example to use port 81: `jewelcat -install -install-port 81`.

### Running in the foreground

Run: `jewelcat`

jewelcat will startup by default using the directory `~/.jewelcat`, looking for symlinks to apps just like pow. Drop a symlink to your app in there as: `cd ~/.jewelcat; ln -s /path/to/my/app example`. You can now access your app as `example.test`.

Running `jewelcat` in this way will require you to use the listed http port, which is `9280` by default.

### Coming from Pow

By default, jewelcat uses the domain `.test` to manage your apps. If you want to have jewelcat look for apps in `~/.pow`, just run `jewelcat -pow`.

## Configuration

jewelcat supports loading environment variables before puma starts. It checks for the following files in this order:

* `.env`
* `.powrc`
* `.powenv`

Additionally, jewelcat uses a few environment variables to control how puma is started that you can overwrite in your loaded shell config.

* `CONFIG`: A puma configuration file to load, usually something like `config/jewelcat.rb`. Defaults to no config.
* `THREADS`: How many threads puma should use concurrently. Defaults to 5.
* `WORKERS`: How many worker processes to start. Defaults to 0, meaning only use threads.

## Purging

If you would like to have jewelcat stop all the apps (for resource issues or because an app isn't restarting properly), you can send `jewelcat` the signal `USR1`. The easiest way to do that is:

`jewelcat -stop`

### Uninstall (OS X only)

Run: `jewelcat -uninstall`

## App usage

Simply symlink your apps directory into `~/.jewelcat`! That's it!

### Proxy support

jewelcat can also proxy requests from a nice dev domain to another app. To do so, just write a file (rather than a symlink'd directory) into `~/.jewelcat` with the connection information.

For example, to have port 9292 show up as `awesome.test`: `echo 9292 > ~/.jewelcat/awesome`.

Or to proxy to another host: `echo 10.3.1.2:9292 > ~/.jewelcat/awesome-elsewhere`.

### HTTPS

jewelcat automatically makes the apps available via SSL as well. When you first run jewelcat, it will have likely caused a dialog to appear to put in your password. What happened there was jewelcat generates its own CA certification that is stored in `~/Library/Application Support/org.bitbucket.bpollack.jewelcat/cert.pem`.

That CA cert is used to dynamically create certificates for your apps when access to them is requested. It automatically happens, no configuration necessary. The certs are stored entirely in memory so future restarts of jewelcat simply generate new ones.

When `-install` is used (and let's be honest, that's how you want to use jewelcat), then it listens on port 443 by default (configurable with `-install-https-port`) so you can just do `https://blah.test` to access your app via https.

### OS X Logging

When jewelcat is installed as a user agent (the default mode), it will log output from itself and the apps to `~/Library/Logs/jewelcat.log`. You can refer to there to find out if apps have started and look for errors.

In the future, jewelcat will provide an integrated console for this log output.

### Websockets

jewelcat supports websockets natively but you may need to tell your web framework to allow the connections.

In the case of rails, you need to configure rails to allow all websockets or websocket requests from certain domains. The quickest way is to add `config.action_cable.disable_request_forgery_protection = true` to `config/environments/development.rb`. This will allow all websocket connections while in development.

*Do not use disable_request_forgery_protection in production!*

Or you can add something like `config.action_cable.allowed_request_origins = /(\.dev$)|^localhost$/` to allow anything under `.test` as well as `localhost`.

### xip.io

jewelcat supports `xip.io` domains. It will detect them and strip them away, so that your `test` app can be accessed as `test.A.B.C.D.xip.io`.

### Static file support

Like pow, jewelcat support serving static files. If an app has a `public` directory, then any urls that match files within that directory are served. The static files have priority over the app.

### Status API

jewelcat is starting to evolve a status API that can be used to introspect it and the apps. To access it, send a request with the `Host: jewelcat` and the path `/status`, for example: `curl -H "Host: jewelcat" localhost/status`.

The status includes:
  * If it is booting, running, or dead
  * The directory of the app
  * The last 1024 lines the app output

## Subcommands

### `jewelcat link [-n name] [dir]`

Creates links to app directories into your jewelcat directory (`~/.jewelcat` by default).

## Development

To build jewelcat, follow these steps:

* Install [golang](http://golang.org)
* Run `go get bitbucket.org/bpollack/jewelcat/...`
* Run `$GOPATH/bin/jewelcat` to use your new binary

jewelcat uses [govendor](https://github.com/kardianos/govendor) to manage dependencies, so if you're working on jewelcat and need to introduce a new dependency, run `govendor fetch +vendor <package path>` to pull it into `vendor`. Then you can use it from within `jewelcat/src`
