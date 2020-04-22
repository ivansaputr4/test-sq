require 'rails_helper'

RSpec.describe "HospitalService", type: :service do
  describe 'bulk_get' do
    let(:jkt_hospitals) { build_stubbed_list(:hospital, 5, area: 1) }
    let(:bks_hospitals) { build_stubbed_list(:hospital, 5, area: 5) }
    let(:hospitals) { jkt_hospitals + bks_hospitals }

    context 'given no params' do
      let(:params) { {} }
      let(:dbl_limit) { double(:limit) }
      let(:default_offset) { 0 }
      let(:default_limit) { 20 }

      before do
        allow(Hospital).to receive(:limit).with(default_limit).and_return(dbl_limit)
        allow(dbl_limit).to receive(:offset).with(default_offset).and_return(hospitals)
      end

      it "return success" do
        expect(HospitalService.new(params).bulk_get).to eq([hospitals, default_offset, default_limit])
      end
    end

    context 'given params' do
      let(:offset) { 0 }
      let(:limit) { 20 }
      let(:params) {
        {
          area: 'bekasi',
          offset: offset,
          limit: limit
        }
      }
      let(:dbl_area) { double(:area) }
      let(:dbl_limit) { double(:limit) }

      before do
        allow(Hospital).to receive(:where).with(area: params[:area]).and_return(dbl_area)
        allow(dbl_area).to receive(:limit).with(params[:limit]).and_return(dbl_limit)
        allow(dbl_limit).to receive(:offset).with(params[:offset]).and_return(bks_hospitals)
      end

      it "return error" do
        expect(HospitalService.new(params).bulk_get).to eq([bks_hospitals, offset, limit])
      end
    end
  end
end
