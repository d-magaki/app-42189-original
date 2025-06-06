#!/usr/bin/env bash
# exit on error
set -o errexit

bundle install
bundle exec rake assets:precompile
bundle exec rake assets:clean
bundle exec rake db:migrate
# ✅ 本番データの初期投入（最初の一回だけ）
bundle exec rails db:seed
