require 'net/sftp'

class BatchPrintFtp
  def initialize(
    host:     ENV['FTP_HOST'],
    username: ENV['FTP_USERNAME'],
    password: ENV['FTP_PASSWORD']
  )
    @host     = host
    @username = username
    @password = password
  end

  def call(data)
    Net::SFTP.start(host, username, password: password) do |sftp|
      sftp.file.open(filename, 'w') do |file|
        file.puts(data)
      end
    end
  end

  private

  def filename
    "#{Time.zone.today}.csv"
  end

  attr_reader :host
  attr_reader :username
  attr_reader :password
end
