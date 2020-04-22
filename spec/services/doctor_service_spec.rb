require 'rails_helper'

RSpec.describe "DoctorService", type: :service do
  describe 'bulk_get' do
    let(:gen_doctors) { build_stubbed_list(:doctor, 5, specialist: 1) }
    let(:tht_doctors) { build_stubbed_list(:doctor, 5, specialist: 2) }
    let(:doctors) { gen_doctors + tht_doctors }

    context 'given no params' do
      let(:params) { {} }
      let(:dbl_limit) { double(:limit) }
      let(:default_offset) { 0 }
      let(:default_limit) { 20 }

      before do
        allow(Doctor).to receive(:limit).with(default_limit).and_return(dbl_limit)
        allow(dbl_limit).to receive(:offset).with(default_offset).and_return(doctors)
      end

      it "return success" do
        expect(DoctorService.new(params).bulk_get).to eq([doctors, default_offset, default_limit])
      end
    end

    context 'given params' do
      let(:offset) { 0 }
      let(:limit) { 20 }
      let(:params) {
        {
          specialist: 'tht',
          offset: offset,
          limit: limit
        }
      }
      let(:dbl_specialist) { double(:specialist) }
      let(:dbl_limit) { double(:limit) }

      before do
        allow(Doctor).to receive(:where).with(specialist: params[:specialist]).and_return(dbl_specialist)
        allow(dbl_specialist).to receive(:limit).with(params[:limit]).and_return(dbl_limit)
        allow(dbl_limit).to receive(:offset).with(params[:offset]).and_return(tht_doctors)
      end

      it "return error" do
        expect(DoctorService.new(params).bulk_get).to eq([tht_doctors, offset, limit])
      end
    end
  end

  describe 'book' do
    let(:patient) { build_stubbed(:user) }
    let(:doctor) { build_stubbed(:doctor) }

    context 'given invalid params' do
      let(:params) {
        {
          schedule_session: "1",
          doctor: doctor,
          patient_id: patient.id
        }
      }

      it "return error" do
        expect{ DoctorService.new(params).book }.to raise_error("invalid params")
      end
    end

    context 'given valid params' do
      let(:params) {
        {
          booking_date: booking_date,
          schedule_session: schedule_session,
          doctor: doctor,
          patient_id: patient.id
        }
      }

      before do
        allow(Time).to receive_message_chain(:now, :localtime).and_return(Time.parse("2020-04-23 15:00"))
      end

      context 'should pass all validations' do
        let(:booking_date) { "2020-04-23" }
        let(:schedule_session) { "1" }
        let(:wday) { 4 }
        let(:dbl_doctor_schedules) { double(:doctor_schedules) }
        let(:dbl_doctor_schedules_2) { double(:doctor_schedules_2) }
        let(:doctor_schedule) { build_stubbed(:doctor_schedule, day_of_week: wday, start_hour: 16, end_hour: 22, doctor: doctor) }
        let(:dbl_booking_schedules) { double(:booking_schedules) }
        let(:dbl_booking_schedules_2) { double(:booking_schedules_2) }
        let(:booking_schedule) { build_stubbed(:booking_schedule, booking_date: booking_date, schedule_session: schedule_session, doctor: doctor, patient: patient) }

        before do
          allow(doctor).to receive(:doctor_schedules).and_return(dbl_doctor_schedules)
          allow(dbl_doctor_schedules).to receive(:where).with(day_of_week: wday, schedule_session: schedule_session.to_i).and_return(dbl_doctor_schedules_2)
          allow(dbl_doctor_schedules_2).to receive(:first).and_return(doctor_schedule)

          allow(doctor).to receive(:booking_schedules).and_return(dbl_booking_schedules)
          allow(dbl_booking_schedules).to receive(:where).with(booking_date: booking_date.to_date, schedule_session: schedule_session.to_i).and_return(dbl_booking_schedules_2)
          allow(dbl_booking_schedules_2).to receive(:count).and_return(0)
          allow(dbl_booking_schedules_2).to receive(:pluck).and_return([])

          allow(BookingSchedule).to receive(:new).and_return(booking_schedule)
          allow(booking_schedule).to receive(:save!).and_return(true)
        end

        it "return success" do
          expect(DoctorService.new(params).book).to eq(booking_schedule)
        end
      end

      context 'should error when save booking_schedule' do
        let(:booking_date) { "2020-04-23" }
        let(:schedule_session) { "1" }
        let(:wday) { 4 }
        let(:dbl_doctor_schedules) { double(:doctor_schedules) }
        let(:dbl_doctor_schedules_2) { double(:doctor_schedules_2) }
        let(:doctor_schedule) { build_stubbed(:doctor_schedule, day_of_week: wday, start_hour: 16, end_hour: 22, doctor: doctor) }
        let(:dbl_booking_schedules) { double(:booking_schedules) }
        let(:dbl_booking_schedules_2) { double(:booking_schedules_2) }
        let(:booking_schedule) { build_stubbed(:booking_schedule, booking_date: booking_date, schedule_session: schedule_session, doctor: doctor, patient: patient) }

        before do
          allow(doctor).to receive(:doctor_schedules).and_return(dbl_doctor_schedules)
          allow(dbl_doctor_schedules).to receive(:where).with(day_of_week: wday, schedule_session: schedule_session.to_i).and_return(dbl_doctor_schedules_2)
          allow(dbl_doctor_schedules_2).to receive(:first).and_return(doctor_schedule)

          allow(doctor).to receive(:booking_schedules).and_return(dbl_booking_schedules)
          allow(dbl_booking_schedules).to receive(:where).with(booking_date: booking_date.to_date, schedule_session: schedule_session.to_i).and_return(dbl_booking_schedules_2)
          allow(dbl_booking_schedules_2).to receive(:count).and_return(0)
          allow(dbl_booking_schedules_2).to receive(:pluck).and_return([])

          allow(BookingSchedule).to receive(:new).and_return(booking_schedule)
          allow(booking_schedule).to receive(:save!).and_raise
        end

        it "raise error" do
          expect{ DoctorService.new(params).book }.to raise_error
        end
      end

      context 'should error when double booking' do
        let(:booking_date) { "2020-04-23" }
        let(:schedule_session) { "1" }
        let(:wday) { 4 }
        let(:dbl_doctor_schedules) { double(:doctor_schedules) }
        let(:dbl_doctor_schedules_2) { double(:doctor_schedules_2) }
        let(:doctor_schedule) { build_stubbed(:doctor_schedule, day_of_week: wday, start_hour: 16, end_hour: 22, doctor: doctor) }
        let(:dbl_booking_schedules) { double(:booking_schedules) }
        let(:booking_schedule) { build_stubbed(:booking_schedule, booking_date: booking_date, schedule_session: schedule_session, doctor: doctor, patient: patient) }

        before do
          allow(doctor).to receive(:doctor_schedules).and_return(dbl_doctor_schedules)
          allow(dbl_doctor_schedules).to receive(:where).with(day_of_week: wday, schedule_session: schedule_session.to_i).and_return(dbl_doctor_schedules_2)
          allow(dbl_doctor_schedules_2).to receive(:first).and_return(doctor_schedule)

          allow(doctor).to receive(:booking_schedules).and_return(dbl_booking_schedules)
          allow(dbl_booking_schedules).to receive(:where).with(booking_date: booking_date.to_date, schedule_session: schedule_session.to_i).and_return([booking_schedule])
        end

        it "raise error" do
          expect{ DoctorService.new(params).book }.to raise_error('Kamu sudah memesan pada jadwal sesi ini')
        end
      end

      context 'should error maximum patient limit per session per doctor' do
        let(:booking_date) { "2020-04-23" }
        let(:schedule_session) { "1" }
        let(:wday) { 4 }
        let(:dbl_doctor_schedules) { double(:doctor_schedules) }
        let(:dbl_doctor_schedules_2) { double(:doctor_schedules_2) }
        let(:doctor_schedule) { build_stubbed(:doctor_schedule, day_of_week: wday, start_hour: 16, end_hour: 22, doctor: doctor) }
        let(:dbl_booking_schedules) { double(:booking_schedules) }
        let(:booking_schedules) { build_stubbed_list(:booking_schedule, 10, booking_date: booking_date, schedule_session: schedule_session, doctor: doctor, patient: patient) }

        before do
          allow(doctor).to receive(:doctor_schedules).and_return(dbl_doctor_schedules)
          allow(dbl_doctor_schedules).to receive(:where).with(day_of_week: wday, schedule_session: schedule_session.to_i).and_return(dbl_doctor_schedules_2)
          allow(dbl_doctor_schedules_2).to receive(:first).and_return(doctor_schedule)

          allow(doctor).to receive(:booking_schedules).and_return(dbl_booking_schedules)
          allow(dbl_booking_schedules).to receive(:where).with(booking_date: booking_date.to_date, schedule_session: schedule_session.to_i).and_return(booking_schedules)
        end

        it "raise error" do
          expect{ DoctorService.new(params).book }.to raise_error('Jadwal dokter hari ini sudah mencapai batas maksimum pasien')
        end
      end

      context 'should error booking_time less than 30 minutes from start doctor schedule session' do
        let(:booking_date) { "2020-04-23" }
        let(:schedule_session) { "1" }
        let(:wday) { 4 }
        let(:dbl_doctor_schedules) { double(:doctor_schedules) }
        let(:dbl_doctor_schedules_2) { double(:doctor_schedules_2) }
        let(:doctor_schedule) { build_stubbed(:doctor_schedule, day_of_week: wday, start_hour: 16, end_hour: 22, doctor: doctor) }

        before do
          allow(doctor).to receive(:doctor_schedules).and_return(dbl_doctor_schedules)
          allow(dbl_doctor_schedules).to receive(:where).with(day_of_week: wday, schedule_session: schedule_session.to_i).and_return(dbl_doctor_schedules_2)
          allow(dbl_doctor_schedules_2).to receive(:first).and_return(doctor_schedule)

          allow(Time).to receive_message_chain(:now, :localtime).and_return(Time.parse("2020-04-23 15:30:01"))
        end

        it "raise error" do
          expect{ DoctorService.new(params).book }.to raise_error('Silahkan memesan jadwal sesi yang lain')
        end
      end

      context 'should error booking_time less than time_now' do
        let(:booking_date) { "2020-04-23" }
        let(:schedule_session) { "1" }
        let(:wday) { 4 }
        let(:dbl_doctor_schedules) { double(:doctor_schedules) }
        let(:dbl_doctor_schedules_2) { double(:doctor_schedules_2) }
        let(:doctor_schedule) { build_stubbed(:doctor_schedule, day_of_week: wday, start_hour: 16, end_hour: 22, doctor: doctor) }

        before do
          allow(doctor).to receive(:doctor_schedules).and_return(dbl_doctor_schedules)
          allow(dbl_doctor_schedules).to receive(:where).with(day_of_week: wday, schedule_session: schedule_session.to_i).and_return(dbl_doctor_schedules_2)
          allow(dbl_doctor_schedules_2).to receive(:first).and_return(doctor_schedule)

          allow(Time).to receive_message_chain(:now, :localtime).and_return(Time.parse("2020-04-23 16:00:01"))
        end

        it "raise error" do
          expect{ DoctorService.new(params).book }.to raise_error('Tidak boleh memesan jadwal sesi kurang dari waktu sekarang')
        end
      end

      context 'should error booking_time less than time_now' do
        let(:booking_date) { "2020-04-23" }
        let(:schedule_session) { "1" }
        let(:wday) { 4 }
        let(:dbl_doctor_schedules) { double(:doctor_schedules) }
        let(:dbl_doctor_schedules_2) { double(:doctor_schedules_2) }

        before do
          allow(doctor).to receive(:doctor_schedules).and_return(dbl_doctor_schedules)
          allow(dbl_doctor_schedules).to receive(:where).with(day_of_week: wday, schedule_session: schedule_session.to_i).and_return(dbl_doctor_schedules_2)
          allow(dbl_doctor_schedules_2).to receive(:first).and_return(nil)
        end

        it "raise error" do
          expect{ DoctorService.new(params).book }.to raise_error('Dokter tidak memiliki jadwal sesi pada hari tersebut. Silahkan memesan jadwal sesi yang lain')
        end
      end
    end
  end

  describe 'get_schedules' do
    let(:doctor) { build_stubbed(:doctor) }

    context 'given invalid params' do
      let(:params) { {} }

      it "return error" do
        expect{ DoctorService.new(params).get_schedules }.to raise_error("invalid params")
      end
    end

    context 'given no params' do
      let(:params) {
        {
          doctor: doctor
        }
      }
      let(:booking_date) { "2020-04-23" }
      let(:schedule_session) { "1" }
      let(:patient) { build_stubbed(:user) }
      let(:booking_schedules) { build_stubbed_list(:booking_schedule, 1, booking_date: booking_date, schedule_session: schedule_session, doctor: doctor, patient: patient) }

      before do
        allow(Date).to receive(:today).and_return(booking_date.to_date)
        allow(doctor).to receive_message_chain(:booking_schedules, :where).and_return(booking_schedules)
      end

      it "return success" do
        expect(DoctorService.new(params).get_schedules).to eq(booking_schedules)
      end
    end

    context 'given params schedule_session' do
      let(:booking_date) { "2020-04-23" }
      let(:schedule_session) { "1" }
      let(:patient) { build_stubbed(:user) }
      let(:dbl_booking_schedules) { double(:booking_schedules) }
      let(:booking_schedules) { build_stubbed_list(:booking_schedule, 1, booking_date: booking_date, schedule_session: schedule_session, doctor: doctor, patient: patient) }
      let(:params) {
        {
          doctor: doctor,
          schedule_session: schedule_session
        }
      }

      before do
        allow(Date).to receive(:today).and_return(booking_date.to_date)
        allow(doctor).to receive_message_chain(:booking_schedules, :where).and_return(dbl_booking_schedules)
        allow(dbl_booking_schedules).to receive(:where).with(schedule_session: schedule_session).and_return(booking_schedules)
      end

      it "return success" do
        expect(DoctorService.new(params).get_schedules).to eq(booking_schedules)
      end
    end
  end
end
