gpsd2influxdb
=============

A simple daemon for importing data from gpsd into an influxdb.
Inspired by https://github.com/mzac/gpsd-influx

# Introduction

This shell script can be run as a daemon, collecting data from gpsd
and writing it to an influxdb.

# Setup

## Hardware

Requires a GPS receiver connected to your device.

## Software

Requires
```
- gpsd
- gpspipe
- influxdb
- jq
- curl
```

gpsd and influxdb need to be set up before running this daemon.

Create a database for gpsd by running

```
influx
CREATE DATABASE "gpsd"
```


A systemd service file for this unit could look like this:

```
[Unit]
Description=gpsd to influxdb
After=syslog.target

[Service]
ExecStart=/usr/local/bin/gpsd2influx
KillMode=control-group
Restart=on-failure

[Install]
WantedBy=multi-user.target
```
