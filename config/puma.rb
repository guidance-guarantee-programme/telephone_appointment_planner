environment ENV.fetch('RACK_ENV', 'development')
workers     @workers = ENV.fetch('WEB_CONCURRENCY', 1)
threads     ENV.fetch('RAILS_MAX_THREADS', 5), ENV.fetch('RAILS_MAX_THREADS', 5)
port        ENV.fetch('PORT', 3000)

preload_app!

before_worker_boot { ActiveRecord::Base.establish_connection } if @workers.to_i > 1
