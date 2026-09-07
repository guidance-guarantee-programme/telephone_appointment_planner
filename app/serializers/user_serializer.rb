class UserSerializer < ActiveModel::Serializer
  attribute :id
  attribute :name, key: :title
  attribute :disabled, key: :suspended
end
