require 'rails_helper'

RSpec.describe 'User API', type: :request do

  # POST /register
  # ############################################################

  describe 'POST /register' do
    let(:user) { build(:user) }

    context 'when username and password is valid' do
      before { register_with(user.username, user.password, user.password_confirmation) } 

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end

      it 'returns the registered user' do
        expect(json).not_to               be_empty
        expect(json['id']).to             be_an(Integer)
        expect(json['username']).to       eq(user.username)
        expect(json['auth_token']).not_to be_empty
      end

      it 'persists the user' do
        expect(User.find_by(username: user.username)).not_to be_nil
      end
    end

    context 'when username is missing' do
      before { register_with(nil, user.password, user.password_confirmation) }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns an username can not be blank message' do
        expect(json).not_to       be_empty
        expect(json['errors']).to match_array(["Username can't be blank"])
      end

      it 'does not persists the user' do
        expect(User.count).to eq(0)
      end
    end

    context 'when password is missing' do
      before { register_with(user.username, nil, nil) }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a password can not be blank message' do
        expect(json).not_to       be_empty
        expect(json['errors']).to match_array(["Password can't be blank",
                                               "Password confirmation can't be blank"])
      end

      it 'does not persist the user' do
        expect(User.count).to eq(0)
      end
    end

    context 'when password confirmation is wrong' do
      before { register_with(user.username, user.password, 'dskf93') }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a password confirmation is wrong message' do
        expect(json).not_to       be_empty
        expect(json['errors']).to match_array(["Password confirmation doesn't match Password"])
      end

      it 'does not persists the user' do
        expect(User.count).to eq(0)
      end
    end

    context 'when the username does already exist' do
      let!(:user) { create(:user) }

      before { register_with(user.username, user.password, user.password_confirmation) }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns an username already exist message' do
        expect(json).not_to       be_empty
        expect(json['errors']).to match_array(['Username has already been taken'])
      end

      it 'does not persists the user' do
        expect(User.count).to eq(1)
      end
    end
  end
end
