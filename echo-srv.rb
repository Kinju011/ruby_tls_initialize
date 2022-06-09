require 'async/io'
# Async do  
  ssl_context = OpenSSL::SSL::SSLContext.new
  # cert = OpenSSL::X509::Certificate.new(File.open("cert.pem"))
  # key = OpenSSL::PKey::RSA.new(File.open("priv.pem"))
  ssl_context.ssl_version = 'TLSv1_1'

  key = OpenSSL::PKey::RSA.new(2048){ print "." }
  puts
  cert = OpenSSL::X509::Certificate.new
  cert.version = 2
  cert.serial = 0
  name = OpenSSL::X509::Name.new([["C","JP"],["O","TEST"],["CN","localhost"]])
  cert.subject = name
  cert.issuer = name
  cert.not_before = Time.now
  cert.not_after = Time.now + 3600
  cert.public_key = key
  ef = OpenSSL::X509::ExtensionFactory.new(nil,cert)
  cert.extensions = [
    ef.create_extension("basicConstraints","CA:FALSE"),
    ef.create_extension("subjectKeyIdentifier","hash"),
    ef.create_extension("extendedKeyUsage","serverAuth"),
    ef.create_extension("keyUsage",
                        "keyEncipherment,dataEncipherment,digitalSignature")
  ]

  ef.issuer_certificate = cert
  cert.add_extension ef.create_extension("authorityKeyIdentifier",
                                         "keyid:always,issuer:always")
  cert.sign(key, "SHA1")

  ssl_context.key = key
  ssl_context.cert = cert
  ssl_context.verify_mode = OpenSSL::SSL::VERIFY_PEER|OpenSSL::SSL::VERIFY_FAIL_IF_NO_PEER_CERT
  ssl_context.ca_path = '/etc/ssl/certs/'
  
  endpoint = TCPServer.new(2000)
  ssl_server = OpenSSL::SSL::SSLServer.new(endpoint, ssl_context)

  loop do
    ns = ssl_server.accept
    puts "connected from #{ns.peeraddr}"
    while line = ns.gets
      puts line.inspect
      ns.write line
    end
    puts "connection closed"
    ns.close
  end
# end
