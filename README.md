# README

This is a simple example of a Rails application that uses the capistrano-puma and sidekiq gems to deploy to a server running Puma and Sidekiq.

## Setup

Create a .env file with the following variables:

```bash
TESTING_SERVER=127.0.0.1 # The IP address of the server you want to deploy to
TESTING_SERVER2= # A second server to deploy to (optional) 
```

```shell
bin/cap {stage} deploy # Where stage is one of the files in config/deploy/
```

## Notes
Currently this application is tested in debian/ubuntu environments. 
Pull requests are welcome to add support for other operating systems.
