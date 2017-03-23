#!/bin/sh

set -e

sleep 15
bin/rake db:migrate
bin/rake spec
