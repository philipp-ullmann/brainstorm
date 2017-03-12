require 'rails_helper'

RSpec.describe 'Brainstorm API', type: :request do
  let!(:health)       { create(:term, name: 'Health') }
  let!(:sleep)        { create(:term, name: 'Sleep', parent: health) }
  let!(:stress)       { create(:term, name: 'Stress', parent: health) }
  let!(:current_user) { health.user }
	let(:valid_token)   { JsonWebToken.encode({ user_id: current_user.id }) }

  # GET /
  # ############################################################

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
        expect(json[0]['owned_by']).to       eq(current_user.username)
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

  # GET /terms/:id
  # ############################################################

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
        expect(json['owned_by']).to                      eq(current_user.username)
        expect(json['created_at']).not_to                be_empty
        expect(json['updated_at']).not_to                be_empty
        expect(json['children']).not_to                  be_empty
        expect(json['children'].size).to                 eq(2)
        expect(json['children'][0]['id']).to             eq(sleep.id)
        expect(json['children'][0]['name']).to           eq(sleep.name)
        expect(json['children'][0]['owned_by']).to       eq(sleep.user.username)
        expect(json['children'][0]['created_at']).not_to be_empty
        expect(json['children'][0]['updated_at']).not_to be_empty
        expect(json['children'][0]['children']).to       be_empty
        expect(json['children'][1]['id']).to             eq(stress.id)
        expect(json['children'][1]['name']).to           eq(stress.name)
        expect(json['children'][1]['owned_by']).to       eq(stress.user.username)
        expect(json['children'][1]['created_at']).not_to be_empty
        expect(json['children'][1]['updated_at']).not_to be_empty
        expect(json['children'][1]['children']).to       be_empty
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

  # POST /terms
  # ############################################################

  describe 'POST /terms' do

    context 'when an user successfully creates a new brainstorming root term' do
      before { post("/terms",
                    params:  { name: 'Climbing' },
                    headers: { accept:        'application/json',
                               authorization: valid_token }) }

			it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end

      it 'returns the brainstorming tree' do
        expect(json).not_to               be_empty
        expect(json['id']).to             be_an(Integer)
        expect(json['name']).to           eq('Climbing')
        expect(json['owned_by']).to       eq(current_user.username)
        expect(json['created_at']).not_to be_empty
        expect(json['updated_at']).not_to be_empty
        expect(json['children']).to       be_empty
      end
    end

    context 'when an user tries to create a new brainstorming root term with an empty name' do
      before { post("/terms",
                    params:  { name: '' },
                    headers: { accept:        'application/json',
                               authorization: valid_token }) }

			it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns an error message' do
        expect(json).not_to       be_empty
        expect(json['errors']).to match_array(["Name can't be blank"])
      end
    end

    context 'when an user tries to create a new brainstorming root term with an name that already exists' do
      before { post("/terms",
                    params:  { name: health.name },
                    headers: { accept:        'application/json',
                               authorization: valid_token }) }

			it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns an error message' do
        expect(json).not_to       be_empty
        expect(json['errors']).to match_array(['Name has already been taken'])
      end
    end

    context 'when an not authenticated user tries to create a new brainstorming root term' do
      before { post("/terms",
                    params:  { name: 'Climbing' },
                    headers: { accept: 'application/json', }) }

			it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

			it 'returns an error' do
        expect(json).not_to 			be_empty
        expect(json['errors']).to match_array(['Invalid Request'])
      end
    end
  end

  # POST /terms?parent_id=:id
  # ############################################################

  describe 'POST /terms' do

    context 'when an user successfully creates a new child term' do
      before { post("/terms?parent_id=#{health.id}",
                    params:  { name: 'Climbing' },
                    headers: { accept:        'application/json',
                               authorization: valid_token }) }

			it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end

      it 'returns the child tree' do
        expect(json).not_to               be_empty
        expect(json['id']).to             be_an(Integer)
        expect(json['name']).to           eq('Climbing')
        expect(json['owned_by']).to       eq(current_user.username)
        expect(json['created_at']).not_to be_empty
        expect(json['updated_at']).not_to be_empty
        expect(json['children']).to       be_empty

        expect(health.children.find_by(name: 'Climbing')).not_to be_nil 
      end
    end

    context 'when an user tries to create a new child term for a parent that does not exist' do
      before { post("/terms?parent_id=0",
                    params:  { name: 'Climbing' },
                    headers: { accept:        'application/json',
                               authorization: valid_token }) }

			it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

			it 'returns an error' do
        expect(json).not_to 			be_empty
        expect(json['errors']).to match_array(["Couldn't find Term with 'id'=0"])

        expect(Term.find_by(name: 'Climbing')).to be_nil 
      end
    end
  end

  # PUT /terms/:id
  # ############################################################

  describe 'PUT /terms/:id' do

    context 'when an user successfully updates the name of a term' do
      before { put("/terms/#{sleep.id}",
                   params:  { name: 'Exercise' },
                   headers: { accept:        'application/json',
                              authorization: JsonWebToken.encode({ user_id: sleep.user.id }) }) }

			it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns the term' do
        expect(json).not_to               be_empty
        expect(json['id']).to             eq(sleep.id)
        expect(json['name']).to           eq('Exercise')
        expect(json['owned_by']).to       eq(sleep.user.username)
        expect(json['created_at']).not_to be_empty
        expect(json['updated_at']).not_to be_empty
        expect(json['children']).to       be_empty

        expect(Term.find_by(name: 'Exercise')).not_to be_nil 
      end
    end

    context 'when an user tries to update a term with an empty name' do
      before { put("/terms/#{sleep.id}",
                    params:  { name: '' },
                    headers: { accept:        'application/json',
                               authorization: JsonWebToken.encode({ user_id: sleep.user.id }) }) }

			it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns an error message' do
        expect(json).not_to       be_empty
        expect(json['errors']).to match_array(["Name can't be blank"])

        expect(Term.find_by(name: sleep.name)).not_to be_nil 
      end
    end

    context 'when an user tries to update a term with an name that already exists' do
      before { put("/terms/#{sleep.id}",
                    params:  { name: stress.name },
                    headers: { accept:        'application/json',
                               authorization: JsonWebToken.encode({ user_id: sleep.user.id }) }) }

			it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns an error message' do
        expect(json).not_to       be_empty
        expect(json['errors']).to match_array(['Name has already been taken'])

        expect(Term.find_by(name: sleep.name)).not_to be_nil 
      end
    end

    context 'when an not authenticated user tries to update a term' do
      before { put("/terms/#{sleep.id}",
                    params:  { name: 'Exercise' },
                    headers: { accept: 'application/json', }) }

			it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

			it 'returns an error' do
        expect(json).not_to 			be_empty
        expect(json['errors']).to match_array(['Invalid Request'])

        expect(Term.find_by(name: 'Exercise')).to be_nil 
      end
    end
  end
end
