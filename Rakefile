# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

default_tasks = [:spec]

begin
  # Rubocop is not available in envs other than development and test.
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
  default_tasks << :rubocop
rescue LoadError
end

default_tasks << :'js:lint'

task default: default_tasks
