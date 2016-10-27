FactoryGirl.define do
  factory :activity do
    user
    appointment
    message 'did a thing to a thing'
    type 'AuditActivity'
  end
end
