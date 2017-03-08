#!/bin/sh

set -e

rake db:migrate
rake spec
