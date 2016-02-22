web: unicorn_rails -c config/unicorn.rb
scheduler: bundle exec rake resque:scheduler
worker: bundle exec rake TERM_CHILD=1 QUEUES=* environment resque:work
