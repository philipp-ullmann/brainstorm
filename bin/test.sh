#!/bin/sh

set -e

sleep 15
rake db:migrate
rake spec
