namespace :js do
  desc 'lint all js'
  task :lint do
    system 'yarn run js'
  end
end
