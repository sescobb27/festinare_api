require 'openssl'

Rails.application.config.PRIVATE_KEY = OpenSSL::PKey::RSA.new(
  File.read('cg.rsa')
).freeze

Rails.application.config.PUBLIC_KEY = OpenSSL::PKey::RSA.new(
  File.read('cg.rsa.pub')
).freeze
