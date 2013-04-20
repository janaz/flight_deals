#!/bin/bash
cd $HOME/github/flight_deals/
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
rvm gemdir
bundle install
bundle exec ./run.rb $@

