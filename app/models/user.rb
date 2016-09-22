class User < ApplicationRecord
  include GDS::SSO::User
  serialize :permissions, Array
  RESOURCE_MANAGER_PERMISSION = 'resource_manager'.freeze
end
