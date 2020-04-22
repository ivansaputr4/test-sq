require 'rails_helper'

RSpec.describe "Doctors", type: :request do
  let(:current_user) { build_stubbed(:user) }

  before do
    allow(User).to receive(:find).with(current_user.id).and_return(current_user)
    api_host!
  end

  describe 'index' do
    let(:http_path) { "/doctors" }
    let(:gen_doctors) { build_stubbed_list(:doctor, 5, specialist: 1) }
    let(:tht_doctors) { build_stubbed_list(:doctor, 5, specialist: 2) }
    let(:doctors) { gen_doctors + tht_doctors }
    let(:dbl_doctor_service) { double(:doctor_service) }

    context 'given no params' do
      let(:http_params) { {} }

      before do
        allow(DoctorService).to receive(:new).with(http_params).and_return(dbl_doctor_service)
        allow(dbl_doctor_service).to receive(:bulk_get).and_return([doctors, 0, 20])
        do_request(:get)
      end

      it "return all doctors" do
        expect(response).to have_http_status(200)

        data = JSON.parse(response.body)['data']
        expect(data[0]['name']).to eq('Dr. Ivan')
        expect(data[0]['specialist']).to eq('general')

        meta = JSON.parse(response.body)['meta']
        expect(meta['offset']).to eq(0)
        expect(meta['limit']).to eq(20)
        expect(meta['total']).to eq(10)
      end
    end

    context 'given params' do
      let(:http_params) { ActionController::Parameters.new({specialist: 2, offset: 5, limit: 5}).permit }

      before do
        allow(DoctorService).to receive(:new).with(http_params).and_return(dbl_doctor_service)
        allow(dbl_doctor_service).to receive(:bulk_get).and_return([tht_doctors, 5, 5])
        do_request(:get)
      end

      it "return doctors with tht specialist" do
        expect(response).to have_http_status(200)

        data = JSON.parse(response.body)['data']
        expect(data[0]['name']).to eq('Dr. Ivan')
        expect(data[0]['specialist']).to eq('tht')

        meta = JSON.parse(response.body)['meta']
        expect(meta['offset']).to eq(5)
        expect(meta['limit']).to eq(5)
        expect(meta['total']).to eq(5)
      end
    end
  end

  describe 'book' do
    let(:booking_date) { "2020-04-23" }
    let(:schedule_session) { "1" }
    let(:doctor) { build_stubbed(:doctor) }
    let(:doctor_schedule) { build_stubbed(:doctor_schedule, day_of_week: 4, start_hour: 19, end_hour: 22, doctor: doctor) }
    let(:booking_schedule) { build_stubbed(:booking_schedule, booking_date: booking_date, schedule_session: schedule_session, doctor: doctor, patient: current_user) }
    let(:dbl_doctor_service) { double(:doctor_service) }
    let(:http_path) { "/doctors/#{doctor.id}/book" }

    before do
      allow(Doctor).to receive(:find_by_id!).with(doctor.id.to_s).and_return(doctor)
    end

    context 'given params' do
      let(:http_params) {
        {
          booking_date: booking_date,
          schedule_session: schedule_session,
          doctor: doctor,
          patient_id: current_user.id
        }.with_indifferent_access
      }

      before do
        allow(DoctorService).to receive(:new).with(http_params).and_return(dbl_doctor_service)
        allow(dbl_doctor_service).to receive(:book).and_return(booking_schedule)
        do_request(:post)
      end

      it "return created" do
        expect(response).to have_http_status(201)
      end
    end

    context 'given no params' do
      let(:http_params) {
        {
          doctor: doctor,
          patient_id: current_user.id
        }.with_indifferent_access
      }

      before do
        allow(DoctorService).to receive(:new).with(http_params).and_return(dbl_doctor_service)
        allow(dbl_doctor_service).to receive(:book).and_raise(StandardError.new("invalid params"))
        do_request(:post)
      end

      it "return error" do
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'schedules' do
    let(:doctor) { build_stubbed(:doctor) }
    let(:http_path) { "/doctors/#{doctor.id}/schedules" }
    let(:http_params) { { id: doctor.id } }
    let(:dbl_doctor_service) { double(:doctor_service) }
    let(:booking_date) { "2020-04-23" }
    let(:schedule_session) { "1" }
    let(:patient) { build_stubbed(:user) }
    let(:booking_schedules) { build_stubbed_list(:booking_schedule, 1, booking_date: booking_date, schedule_session: schedule_session, doctor: doctor, patient: patient) }

    context 'should get booking_schedules' do
      before do
        allow(DoctorService).to receive(:new).and_return(dbl_doctor_service)
        allow(dbl_doctor_service).to receive(:get_schedules).and_return(booking_schedules)
        allow(Doctor).to receive(:find_by_id!).and_return(doctor)
        do_request(:get)
      end

      it "return booking_schedules" do
        expect(response).to have_http_status(200)

        data = JSON.parse(response.body)['data']
        expect(data[0]['booking_date']).to eq(booking_date)
        expect(data[0]['schedule_session']).to eq(schedule_session.to_i)

        meta = JSON.parse(response.body)['meta']
      end
    end
  end
end
