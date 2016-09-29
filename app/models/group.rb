class Group < ApplicationRecord
  default_scope { order(:name) }
end
