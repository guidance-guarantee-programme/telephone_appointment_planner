namespace :js do
  desc 'lint all js'
  task lint: :environment do
    sh 'npm run js'
  end
end
