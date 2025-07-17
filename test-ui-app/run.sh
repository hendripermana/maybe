#!/bin/bash

# Install required gems if not already installed
gem list -i sinatra || gem install sinatra
gem list -i sinatra-reloader || gem install sinatra-reloader

# Run the application
ruby app.rb