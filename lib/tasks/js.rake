namespace :js do
  desc 'lint all js'
  task :lint do
    bin = command?('yarn') ? 'yarn' : 'npm'
    sh "#{bin} run js"
  end

  def command?(name)
    `which #{name}`
    $CHILD_STATUS.success?
  end
end
