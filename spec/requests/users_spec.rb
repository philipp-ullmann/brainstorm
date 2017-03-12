require 'rails_helper'

RSpec.describe 'User API', type: :request do

  # POST /register
  # ############################################################

  describe 'POST /register' do
    let(:valid_attr) { attributes_for(:user) }

    context 'with valid attributes' do
      before { post('/register',
                    params:  valid_attr,
                    headers: { accept: 'application/json' }) }

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end

      it 'returns the new user' do
        expect(json).not_to               be_empty
        expect(json['id']).to             be_an(Integer)
        expect(json['username']).to       eq(valid_attr[:username])
        expect(json['auth_token']).not_to be_empty
      end
    end

    context 'without username' do
      before { post('/register',
                    params:  valid_attr.without(:username),
                    headers: { accept: 'application/json' }) }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns an error message' do
        expect(json).not_to       be_empty
        expect(json['errors']).to match_array(["Username can't be blank"])
      end
    end

    context 'without password' do
      before { post('/register',
                    params:  valid_attr.without(:password, :password_confirmation),
                    headers: { accept: 'application/json' }) }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns an error message' do
        expect(json).not_to       be_empty
        expect(json['errors']).to match_array(["Password can't be blank",
                                               "Password confirmation can't be blank"])
      end
    end

    context 'with a wrong password confirmation' do
      before { post('/register',
                    params:  attributes_for(:user, password_confirmation: 'dskf93'),
                    headers: { accept: 'application/json' }) }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns an error message' do
        expect(json).not_to       be_empty
        expect(json['errors']).to match_array(["Password confirmation doesn't match Password"])
      end
    end

    context 'with an username that already exist' do
      let!(:philipp) { create(:user, username: 'philipp') }

      before { post('/register',
                    params:  attributes_for(:user, username: 'Philipp'),
                    headers: { accept: 'application/json' }) }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns an error message' do
        expect(json).not_to       be_empty
        expect(json['errors']).to match_array(['Username has already been taken'])
      end
    end
  end
end
