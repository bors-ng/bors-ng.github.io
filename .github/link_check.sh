#!/bin/bash
bundle install
gem install html-proofer
bundle exec jekyll build
htmlproofer ./_site/ --disable-external

