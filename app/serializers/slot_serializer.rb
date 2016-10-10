class SlotSerializer < ActiveModel::Serializer
  attributes(
    :day_of_week,
    :start_hour,
    :start_minute,
    :end_hour,
    :end_minute
  )
end
