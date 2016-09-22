# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

default_tasks = [:spec]

begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
  default_tasks.unshift(:rubocop)
rescue LoadError
end

task default: default_tasks
