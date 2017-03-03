require 'rails_helper'

RSpec.describe 'Registration API', type: :request do

  describe 'POST /register.json' do

    context 'when the user is valid' do
      before { post('/register',
										params:  { username: 'philipp', password: 'secret', password_confirmation: 'secret' },
									  headers: { accept: 'application/json' }) }

			it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end

			it 'returns the user' do
        expect(json).not_to 							be_empty
        expect(json['id']).to 						be_an(Integer)
        expect(json['username']).to 			eq('philipp')
        expect(json['auth_token']).not_to be_empty
      end
    end

  end
end
