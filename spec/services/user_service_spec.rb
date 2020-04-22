require 'rails_helper'

RSpec.describe "UserService", type: :service do
  describe 'register' do
    let(:user) { build_stubbed(:user) }

    context 'when using email' do
      context 'given all required registration params' do
        let(:params) {
          {
            name: user.name,
            email: user.email,
            password: user.password,
            password_confirmation: user.password_confirmation
          }
        }

        before do
          allow(User).to receive(:new).with(params).and_return(user)
          allow(user).to receive(:save!).and_return(true)
        end

        it "return success" do
          expect(UserService.new(params).register).to eq(user)
        end
      end

      context 'given invalid params' do
        let(:params) {
          {
            name: user.name,
            email: user.email,
            password: user.password
          }
        }

        it "return error" do
          expect{ UserService.new(params).register }.to raise_error("invalid params")
        end
      end
    end
  end

  describe 'login' do
    let(:user) { build_stubbed(:user) }

    context 'when using email' do
      context 'given all required registration params' do
        let(:params) {
          {
            email: user.email,
            password: user.password
          }
        }

        before do
          allow(User).to receive(:find_by_email!).with(params[:email]).and_return(user)
          allow(user).to receive(:authenticate).with(params[:password]).and_return(true)
        end

        it "return success" do
          expect(UserService.new(params).login).to eq(user)
        end
      end

      context 'given invalid email' do
        let(:params) {
          {
            email: "abc@abc.com",
            password: user.password
          }
        }

        it "raise error not found" do
          expect{ UserService.new(params).login }.to raise_error(ActiveRecord::RecordNotFound, "Couldn't find User")
        end
      end

      context 'given invalid password' do
        let(:params) {
          {
            email: user.email,
            password: "654321"
          }
        }

        before do
          allow(User).to receive(:find_by_email!).with(params[:email]).and_return(user)
          allow(user).to receive(:authenticate).with(params[:password]).and_return(false)
        end

        it "raise error unauthorized" do
          expect{ UserService.new(params).login }.to raise_error("unauthorized")
        end
      end

      context 'given invalid params' do
        let(:params) {
          {
            email: user.email
          }
        }

        it "raise error invalid params" do
          expect{ UserService.new(params).login }.to raise_error("invalid params")
        end
      end
    end
  end
end
