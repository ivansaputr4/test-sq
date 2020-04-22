require 'rails_helper'

RSpec.describe "Hospitals", type: :request do

  let(:current_user) { build_stubbed(:user) }
  before do
    allow(User).to receive(:find).with(current_user.id).and_return(current_user)
    api_host!
  end

  describe 'index' do
    let(:http_path) { "/hospitals" }
    let(:jkt_hospitals) { build_stubbed_list(:hospital, 5, area: 1) }
    let(:bks_hospitals) { build_stubbed_list(:hospital, 5, area: 5) }
    let(:hospitals) { jkt_hospitals + bks_hospitals }
    let(:dbl_hospital_service) { double(:hospital_service) }

    context 'given no params' do
      let(:http_params) { {} }

      before do
        allow(HospitalService).to receive(:new).with(http_params).and_return(dbl_hospital_service)
        allow(dbl_hospital_service).to receive(:bulk_get).and_return([hospitals, 0, 20])
        do_request(:get)
      end

      it "return all hospitals" do
        expect(response).to have_http_status(200)

        data = JSON.parse(response.body)['data']
        expect(data[0]['name']).to eq('Mitra')
        expect(data[0]['area']).to eq('south_jakarta')
        expect(data[0]['address']).to eq('Jl. Bekasi Timur 12345')

        meta = JSON.parse(response.body)['meta']
        expect(meta['offset']).to eq(0)
        expect(meta['limit']).to eq(20)
        expect(meta['total']).to eq(10)
      end
    end

    context 'given params' do
      let(:http_params) { ActionController::Parameters.new({area: 'bekasi', offset: 5, limit: 5}).permit }

      before do
        allow(HospitalService).to receive(:new).with(http_params).and_return(dbl_hospital_service)
        allow(dbl_hospital_service).to receive(:bulk_get).and_return([bks_hospitals, 5, 5])
        do_request(:get)
      end

      it "return hospitals in Bekasi" do
        expect(response).to have_http_status(200)

        data = JSON.parse(response.body)['data']
        expect(data[0]['name']).to eq('Mitra')
        expect(data[0]['area']).to eq('bekasi')
        expect(data[0]['address']).to eq('Jl. Bekasi Timur 12345')

        meta = JSON.parse(response.body)['meta']
        expect(meta['offset']).to eq(5)
        expect(meta['limit']).to eq(5)
        expect(meta['total']).to eq(5)
      end
    end
  end
end
