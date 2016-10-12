namespace :js do
  desc 'lint all js'
  task :lint do
    sh 'npm run js'
  end
end
