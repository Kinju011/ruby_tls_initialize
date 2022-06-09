require 'async/io'
# Async do
  host = 'localhost'
  port = 2000

  ctx = OpenSSL::SSL::SSLContext.new

  # ctx.cert = OpenSSL::X509::Certificate.new(File.open("cert.pem"))
  # ctx.key = OpenSSL::PKey.read(File::read("priv.pem"))

  ctx.verify_mode = OpenSSL::SSL::VERIFY_PEER
  ctx.ca_path = '/etc/ssl/certs/'

  socket = TCPSocket.new(host, port)
  ssl = OpenSSL::SSL::SSLSocket.new(socket, ctx)
  ssl.connect

  errors = Hash.new
  OpenSSL::X509.constants.grep(/^V_(ERR_|OK)/).each do |name|
    errors[OpenSSL::X509.const_get(name)] = name
  end

  p errors[ssl.verify_result]

  ssl.sync_close = true

  while line = $stdin.gets
    ssl.write line
    puts ssl.gets.inspect
  end
# end
