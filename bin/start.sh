#!/bin/sh

set -e

bin/rake db:migrate
rm -f tmp/pids/server.pid
bin/rails server -p 3000 -b 0.0.0.0
