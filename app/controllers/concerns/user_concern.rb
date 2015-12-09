module UserConcern
  extend ActiveSupport::Concern

  def resource
    # > 'API::V1::UsersController'.demodulize
    #                             .underscore
    #                             .sub(/_controller$/, '')
    # 'users'
    self.class.to_s.demodulize.underscore.sub(/_controller$/, '')
  end

  def resource_name
    # > 'API::V1::UsersController'.demodulize
    #                             .underscore
    #                             .sub(/_controller$/, '')
    #                             .singularize
    # 'user'
    resource.singularize
  end

  def resource_model
    # > 'API::V1::UsersController'.demodulize
    #                             .underscore
    #                             .sub(/_controller$/, '')
    #                             .classify
    #                             .constantize
    # class User < Object {
    #                        :id => :"bson/object_id",
    #                      :_type => :string,
    #       :confirmation_sent_at => :time,
    #         :confirmation_token => :object,
    #               :confirmed_at => :time,
    #                 :created_at => :time,
    #                 :deleted_at => :time,
    #                      :email => :object,
    #         :encrypted_password => :object,
    #     :reset_password_sent_at => :time,
    #       :reset_password_token => :object,
    #                      :token => :array,
    #                   :username => :object
    # }
    resource.classify.constantize
  end
end
