class HolidaySerializer < ActiveModel::Serializer
  attribute :title
  attribute :start do
    object.start_at
  end
  attribute :end do
    object.end_at
  end
end
