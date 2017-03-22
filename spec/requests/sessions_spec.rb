require 'rails_helper'

RSpec.describe 'Session API', type: :request do

  # POST /login
  # ############################################################

  describe 'POST /login' do
    let(:user) { create(:user) }

    context 'when the username and password are valid' do
      before { login_with(user.username, 'secret') } 

      it 'returns a status code of 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns the logged in user' do
        expect(json).not_to               be_empty
        expect(json['id']).to             eq(user.id)
        expect(json['username']).to       eq(user.username)
        expect(json['auth_token']).not_to be_empty
      end
    end

    context 'when the username does not exist' do
      before { login_with('unknown', 'secret') }

      it 'returns a status code of 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns a failed login error message' do
        expect(json).not_to       be_empty
        expect(json['errors']).to match_array(['Invalid username / password'])
      end
    end

    context 'when the password is wrong' do
      before { login_with(user.username, 'Secret') }

      it 'returns a status code of 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns a failed login error message' do
        expect(json).not_to       be_empty
        expect(json['errors']).to match_array(['Invalid username / password'])
      end
    end
  end
end
