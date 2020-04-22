FactoryGirl.define do
  factory :booking_schedule do
    booking_date "2020-04-21"
    schedule_session 1
    state 1

    after :build do |instance|
      instance.doctor = build_stubbed(:doctor)
      instance.patient = build_stubbed(:user)
    end
  end
end
