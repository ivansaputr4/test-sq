FactoryGirl.define do
  factory :doctor_schedule do
    day_of_week 1
    start_hour 10
    end_hour 15
    schedule_session 1

    after :build do |instance|
      instance.doctor = build_stubbed(:doctor)
    end
  end
end
