require 'openssl'

Rails.application.config.private_key = OpenSSL::PKey::RSA.new(File.read('cg.rsa'))
Rails.application.config.public_key = OpenSSL::PKey::RSA.new(File.read('cg.rsa.pub'))
