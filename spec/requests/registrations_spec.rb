require 'rails_helper'

RSpec.describe 'Registration API', type: :request do

  describe 'POST /register.json' do
		let(:valid_attr) { attributes_for(:user) }

    context 'when the user is valid' do
      before { post('/register',
										params:  valid_attr,
									  headers: { accept: 'application/json' }) }

			it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end

			it 'returns the user' do
        expect(json).not_to 							be_empty
        expect(json['id']).to 						be_an(Integer)
        expect(json['username']).to 			eq(valid_attr[:username])
        expect(json['auth_token']).not_to be_empty
      end
    end

    context 'when the user has no username' do
      before { post('/register',
										params:  valid_attr.without(:username),
									  headers: { accept: 'application/json' }) }

			it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns an error' do
        expect(json).not_to 			be_empty
        expect(json['errors']).to match_array(["Username can't be blank"])
      end
    end

    context 'when the user has no password' do
      before { post('/register',
										params:  valid_attr.without(:password, :password_confirmation),
									  headers: { accept: 'application/json' }) }

			it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns an error' do
        expect(json).not_to 			be_empty
        expect(json['errors']).to match_array(["Password can't be blank",
                                               "Password confirmation can't be blank"])
      end
    end

    context 'when the username has already been taken' do
      let!(:philipp) { create(:user, username: 'philipp') }

      before { post('/register',
										params:  attributes_for(:user, username: 'Philipp'),
									  headers: { accept: 'application/json' }) }

			it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns an error' do
        expect(json).not_to 			be_empty
        expect(json['errors']).to match_array(['Username has already been taken'])
      end
    end

    context 'when the password confirmation does not match' do
      before { post('/register',
										params:  attributes_for(:user, password_confirmation: 'dskf93'),
									  headers: { accept: 'application/json' }) }

			it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns an error' do
        expect(json).not_to 			be_empty
        expect(json['errors']).to match_array(["Password confirmation doesn't match Password"])
      end
    end
  end
end
