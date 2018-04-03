require 'uri'
require 'net/ssh'
require 'net/sftp'
require 'net/ssh/proxy/http'

class BatchPrintFtp
  def initialize(
    host:      ENV['FTP_HOST'],
    username:  ENV['FTP_USERNAME'],
    password:  ENV['FTP_PASSWORD'],
    proxy_uri: ENV['QUOTAGUARDSTATIC_URL']
  )
    @host      = host
    @username  = username
    @password  = password
    @proxy_uri = URI(proxy_uri)
  end

  def call(data)
    Net::SFTP.start(host, username, password: password, proxy: proxy) do |sftp|
      sftp.file.open(filename, 'w') do |file|
        file.puts(data)
      end
    end
  end

  private

  def proxy
    Net::SSH::Proxy::HTTP.new(
      proxy_uri.host,
      proxy_uri.port,
      user: proxy_uri.user,
      password: proxy_uri.password
    )
  end

  def filename
    "#{Time.zone.today}.csv"
  end

  attr_reader :host
  attr_reader :username
  attr_reader :password
  attr_reader :proxy_uri
end
