require 'rails_helper'

RSpec.describe 'Brainstorm API', type: :request do
  let!(:health)     { create(:term, name: 'Health') }
  let!(:sleep)      { create(:term, name: 'Sleep', parent: health) }
	let(:valid_token) { JsonWebToken.encode({ user_id: health.user.id }) }

  describe 'GET /' do

    context 'when an user is authenticated' do
      before { get('/', headers: { accept:        'application/json',
                                   authorization: valid_token }) }

			it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

			it 'returns a list of available root brainstorming terms' do
        expect(json).not_to 			           be_empty
        expect(json.size).to                 eq(1)
        expect(json[0]['id']).to             eq(health.id)
        expect(json[0]['name']).to           eq(health.name)
        expect(json[0]['owned_by']).to       eq(health.user.username)
        expect(json[0]['created_at']).not_to be_empty
        expect(json[0]['updated_at']).not_to be_empty
      end
    end

    context 'when an user is not authenticated' do
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

  describe 'GET /terms/:id' do

    context 'when an user tries to view a root term' do
      before { get("/terms/#{health.id}",
                   headers: { accept:        'application/json',
                              authorization: valid_token }) }

			it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns the brainstorming tree' do
        expect(json).not_to                              be_empty
        expect(json['id']).to                            eq(health.id)
        expect(json['name']).to                          eq(health.name)
        expect(json['owned_by']).to                      eq(health.user.username)
        expect(json['created_at']).not_to                be_empty
        expect(json['updated_at']).not_to                be_empty
        expect(json['children']).not_to                  be_empty
        expect(json['children'].size).to                 eq(1)
        expect(json['children'][0]['id']).to             eq(sleep.id)
        expect(json['children'][0]['name']).to           eq(sleep.name)
        expect(json['children'][0]['owned_by']).to       eq(sleep.user.username)
        expect(json['children'][0]['created_at']).not_to be_empty
        expect(json['children'][0]['updated_at']).not_to be_empty
        expect(json['children'][0]['children']).to       be_empty
      end
    end

    context 'when an user tries to view a child term' do
      before { get("/terms/#{sleep.id}",
                   headers: { accept:        'application/json',
                              authorization: valid_token }) }

			it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

			it 'returns an error' do
        expect(json).not_to 			be_empty
        expect(json['errors']).to match_array(["Couldn't find Term with 'id'=#{sleep.id} [WHERE `terms`.`ancestry` IS NULL]"])
      end
    end

    context 'when an user is not authenticated' do
      before { get("/terms/#{health.id}", headers: { accept: 'application/json' }) }

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
