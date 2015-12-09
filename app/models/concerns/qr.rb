require 'rqrcode'

module Qr
  extend ActiveSupport::Concern
  include RQRCode

  included do
    validates :secret_key, presence: true
  end

  def generate_qr(client_id, user_id)
    msg = ActiveSupport::JSON.encode(secret: self.secret_key, client_id: client_id, user_id: user_id)
    qrcode = QRCode.new(msg).as_png
    yield qrcode if block_given?
  end
end
