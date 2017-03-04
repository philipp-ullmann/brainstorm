require 'rails_helper'

RSpec.describe 'Brainstorm API', type: :request do

  describe 'GET /' do
    let(:health)      { create(:term, name: 'Health') }
    let(:sleep)       { create(:term, name: 'Sleep') }
		let(:valid_token) { JsonWebToken.encode({ user_id: health.user.id }) }

    context 'when the the user is authenticated' do
      before { get('/', headers: { accept:        'application/json',
                                   authorization: valid_token }) }

			it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

			it 'returns a list of available root brainstorming terms' do
        expect(json).not_to 			 be_empty
        expect(json.size).to       eq(1)
        expect(json[0]['id']).to   eq(health.id)
        expect(json[0]['name']).to eq(health.name)
      end
    end

    context 'when the the user is not authenticated' do
      before { get('/', headers: { accept: 'application/json' }) }

			it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

			it 'returns an error' do
        expect(json).not_to 			be_empty
        expect(json['errors']).to match_array(['Invalid Request'])
      end
    end
  end
end
