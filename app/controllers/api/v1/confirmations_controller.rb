module API
  module V1
    class ConfirmationsController < Devise::ConfirmationsController
      respond_to :json
    end
  end
end
