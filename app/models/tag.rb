class Tag < ApplicationRecord
  default_scope { order(:name) }
end
