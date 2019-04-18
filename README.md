# Slimme meter stats

Simple application for reading the Dutch "Slimme meter" via the P1 port and generating graphics with RRDtool.

## Requirements

This applications expects an P1 to USB cable connected as `/dev/ttyUSB0`.

The following packages are required:

* Ruby
* RRDtool
* Nginx (or another webserver; example for nginx is included)
* fcgiwrap (when using nginx)

## Installation

Make sure you have installed bundler:

```bash
gem install bundler
```

Run bundle install to install the dependencies:

```bash
bundle install --path vendor
```

Start the slimme meter updater in the background:

```bash
bundle exec ruby slimmemeter.rb -d -r /var/lib/rrd/power.rrd
```

Nginx configuration:

```
server {
  ...

  # Pass CGI scripts to FastCGI server
  location /cgi-bin/ {
    fastcgi_pass  unix:/var/run/fcgiwrap.socket;
    fastcgi_param POWER_RRD /var/lib/rrd/power.rrd;

    include /etc/nginx/fastcgi_params;
  }
}
```

Place the files in the `www` directory of your web directory. Make sure you put the *.cgi files in the cgi-bin directory of your document root.
