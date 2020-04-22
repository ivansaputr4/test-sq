require 'rails_helper'

RSpec.describe "Users", type: :request do
	before { api_host! }

  describe 'register' do
    let(:result) { build_stubbed(:user) }
    let(:http_path) { "/users" }

    before do
      do_request(:post)
    end

    context 'when using email' do
      context 'given all required registration http_params' do
        let(:http_params) {
          {
            email: 'ivan@gmail.com',
            name: 'Ivan',
            password: '123456',
            password_confirmation: '123456'
          }
        }

        it "return success" do
          expect(response).to have_http_status(201)
          
          data = JSON.parse(response.body)['data']
          expect(data['name']).to eq(result.name)
          expect(data['email']).to eq(result.email)
        end
      end

      context 'given invalid http_params' do
        let(:http_params) {
          {
            email: 'ivan@gmail.com',
            name: 'Ivan',
            password: '123456'
          }
        }

        it "return error" do
          expect(response).to have_http_status(422)
        end
      end
    end
  end

  describe 'login' do
  	let(:result) { build_stubbed(:user) }
  	let(:http_path) { "/login" }

    context 'when using email' do
      context 'given valid password' do
        let(:http_params) {
          {
            email: 'ivan@gmail.com',
            password: '123456',
          }
        }

        before do
        	allow(User).to receive(:find_by_email!).and_return(result)
          allow(result).to receive(:authenticate).with(http_params[:password]).and_return(true)
          do_request(:post)
        end

        it "return success" do
          expect(response).to have_http_status(200)

          data = JSON.parse(response.body)
          expect(data).to have_key('token')
          expect(data).to have_key('exp')
        end
      end

      context 'given invalid password' do
        let(:http_params) {
          {
            email: 'ivan@gmail.com',
            password: '1234567',
          }
        }

        before do
        	allow(User).to receive(:find_by_email!).and_return(result)
          allow(result).to receive(:authenticate).with(http_params[:password]).and_return(false)
          do_request(:post)
        end

        it "return error" do
          expect(response).to have_http_status(422)
        end
      end
    end
  end
end
