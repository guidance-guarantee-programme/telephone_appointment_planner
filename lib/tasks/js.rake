namespace :js do
  desc 'lint all js'
  task :lint do
    system 'npm run js'
  end
end
