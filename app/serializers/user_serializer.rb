class UserSerializer < ActiveModel::Serializer
  attribute :id
  attribute :name, key: :title
  attribute :due_diligence?, key: :dueDiligence
end
