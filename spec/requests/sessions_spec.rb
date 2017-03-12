require 'rails_helper'

RSpec.describe 'Session API', type: :request do

  # POST /login
  # ############################################################

  describe 'POST /login' do
    let(:user) { create(:user) }

    context 'with valid credentials' do
      before { post('/login',
                    params:  { username: user.username,
                               password: 'secret' },
                    headers: { accept: 'application/json' }) }

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns the logged in user' do
        expect(json).not_to               be_empty
        expect(json['id']).to             eq(user.id)
        expect(json['username']).to       eq(user.username)
        expect(json['auth_token']).not_to be_empty
      end
    end

    context 'with an username that does not exist' do
      before { post('/login',
                    params:  { username: 'unknown',
                               password: 'secret' },
                    headers: { accept: 'application/json' }) }

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns an error message' do
        expect(json).not_to       be_empty
        expect(json['errors']).to match_array(['Invalid username / password'])
      end
    end

    context 'with a wrong password' do
      before { post('/login',
                    params:  { username: user.username,
                               password: 'Secret' },
                    headers: { accept: 'application/json' }) }

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns an error message' do
        expect(json).not_to       be_empty
        expect(json['errors']).to match_array(['Invalid username / password'])
      end
    end
  end
end
