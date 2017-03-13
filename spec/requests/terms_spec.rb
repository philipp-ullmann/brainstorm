require 'rails_helper'

RSpec.describe 'Brainstorm API', type: :request do
  let!(:health)       { create(:term, name: 'Health') }
  let!(:sleep)        { create(:term, name: 'Sleep', parent: health) }
  let!(:stress)       { create(:term, name: 'Stress', parent: health) }

  # GET /
  # ############################################################

  describe 'GET /' do

    context 'with valid JWT token' do
      before { get('/', headers: { accept:        'application/json',
                                   authorization: health.user.token }) }

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns a list of available root brainstorming terms' do
        expect(json).not_to                  be_empty
        expect(json.size).to                 eq(1)
        expect(json[0]['id']).to             eq(health.id)
        expect(json[0]['name']).to           eq(health.name)
        expect(json[0]['owned_by']).to       eq(health.user.username)
        expect(json[0]['created_at']).not_to be_empty
        expect(json[0]['updated_at']).not_to be_empty
      end
    end

    context 'without JWT token' do
      before { get('/', headers: { accept: 'application/json' }) }

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns an error message' do
        expect(json).not_to       be_empty
        expect(json['errors']).to match_array(['You are not authorized to perform this action'])
      end
    end
  end

  # GET /terms/:id
  # ############################################################

  describe 'GET /terms/:id' do

    context 'when :id is a root term' do
      before { get("/terms/#{health.id}",
                   headers: { accept:        'application/json',
                              authorization: health.user.token }) }

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

    context 'when :id is a child term' do
      before { get("/terms/#{sleep.id}",
                   headers: { accept:        'application/json',
                              authorization: health.user.token }) }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns an error message' do
        expect(json).not_to       be_empty
        expect(json['errors']).to match_array(["Couldn't find Term with 'id'=#{sleep.id} [WHERE `terms`.`ancestry` IS NULL]"])
      end
    end

    context 'without JWT token' do
      before { get("/terms/#{health.id}", headers: { accept: 'application/json' }) }

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns an error message' do
        expect(json).not_to       be_empty
        expect(json['errors']).to match_array(['You are not authorized to perform this action'])
      end
    end
  end

  # POST /terms
  # ############################################################

  describe 'POST /terms' do

    context 'with valid name' do
      before { post("/terms",
                    params:  { name: 'Climbing' },
                    headers: { accept:        'application/json',
                               authorization: health.user.token }) }

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end

      it 'returns the new brainstorming tree' do
        expect(json).not_to               be_empty
        expect(json['id']).to             be_an(Integer)
        expect(json['name']).to           eq('Climbing')
        expect(json['owned_by']).to       eq(health.user.username)
        expect(json['created_at']).not_to be_empty
        expect(json['updated_at']).not_to be_empty
        expect(json['children']).to       be_empty
      end

      it 'creates the root term' do
        expect(Term.roots.find_by(name: 'Climbing')).not_to be_nil
      end
    end

    context 'with an empty name' do
      before { post("/terms",
                    params:  { name: '' },
                    headers: { accept:        'application/json',
                               authorization: health.user.token }) }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns an error message' do
        expect(json).not_to       be_empty
        expect(json['errors']).to match_array(["Name can't be blank"])
      end

      it 'does not create the term' do
        expect(Term.roots.find_by(name: '')).to be_nil
      end
    end

    context 'with a name that has 51 characters' do
      before { post("/terms",
                    params:  { name: Faker::Lorem.characters(51) },
                    headers: { accept:        'application/json',
                               authorization: health.user.token }) }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns an error message' do
        expect(json).not_to       be_empty
        expect(json['errors']).to match_array(['Name is too long (maximum is 50 characters)'])
      end

      it 'does not create the term' do
        expect(Term.roots.count).to be(1)
      end
    end

    context 'with a name that already exists' do
      before { post("/terms",
                    params:  { name: health.name },
                    headers: { accept:        'application/json',
                               authorization: health.user.token }) }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns an error message' do
        expect(json).not_to       be_empty
        expect(json['errors']).to match_array(['Name has already been taken'])
      end

      it 'does not create the term' do
        expect(Term.roots.count).to be(1)
      end
    end

    context 'without a JWT token' do
      before { post("/terms",
                    params:  { name: 'Climbing' },
                    headers: { accept: 'application/json' }) }

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns an error message' do
        expect(json).not_to       be_empty
        expect(json['errors']).to match_array(['You are not authorized to perform this action'])
      end

      it 'does not create the term' do
        expect(Term.roots.find_by(name: 'Climbing')).to be_nil
      end
    end
  end

  # POST /terms?parent_id=:id
  # ############################################################

  describe 'POST /terms?parent_id=:id' do

    context 'with a valid name' do
      before { post("/terms?parent_id=#{health.id}",
                    params:  { name: 'Climbing' },
                    headers: { accept:        'application/json',
                               authorization: health.user.token }) }

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end

      it 'returns the child tree' do
        expect(json).not_to               be_empty
        expect(json['id']).to             be_an(Integer)
        expect(json['name']).to           eq('Climbing')
        expect(json['owned_by']).to       eq(health.user.username)
        expect(json['created_at']).not_to be_empty
        expect(json['updated_at']).not_to be_empty
        expect(json['children']).to       be_empty
      end

      it 'creates the term' do
        expect(health.children.find_by(name: 'Climbing')).not_to be_nil 
      end
    end

    context 'with a parent id that does not exist' do
      before { post("/terms?parent_id=0",
                    params:  { name: 'Climbing' },
                    headers: { accept:        'application/json',
                               authorization: health.user.token }) }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns an error message' do
        expect(json).not_to       be_empty
        expect(json['errors']).to match_array(["Couldn't find Term with 'id'=0"])
      end

      it 'does not create the term' do
        expect(Term.find_by(name: 'Climbing')).to be_nil 
      end
    end
  end

  # PUT /terms/:id
  # ############################################################

  describe 'PUT /terms/:id' do

    context 'with a valid name' do
      before { put("/terms/#{sleep.id}",
                   params:  { name: 'Exercise' },
                   headers: { accept:        'application/json',
                              authorization: sleep.user.token }) }

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns the term tree' do
        expect(json).not_to               be_empty
        expect(json['id']).to             eq(sleep.id)
        expect(json['name']).to           eq('Exercise')
        expect(json['owned_by']).to       eq(sleep.user.username)
        expect(json['created_at']).not_to be_empty
        expect(json['updated_at']).not_to be_empty
        expect(json['children']).to       be_empty
      end

      it 'updates the term' do
        expect(Term.find_by(name: 'Exercise')).not_to be_nil 
      end
    end

    context 'with an empty name' do
      before { put("/terms/#{sleep.id}",
                    params:  { name: '' },
                    headers: { accept:        'application/json',
                               authorization: sleep.user.token }) }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns an error message' do
        expect(json).not_to       be_empty
        expect(json['errors']).to match_array(["Name can't be blank"])
      end

      it 'does not update the term' do
        expect(Term.find_by(name: sleep.name)).not_to be_nil 
      end
    end

    context 'with a name that has 51 characters' do
      before { put("/terms/#{sleep.id}",
                    params:  { name: Faker::Lorem.characters(51) },
                    headers: { accept:        'application/json',
                               authorization: sleep.user.token }) }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns an error message' do
        expect(json).not_to       be_empty
        expect(json['errors']).to match_array(['Name is too long (maximum is 50 characters)'])
      end

      it 'does not update the term' do
        expect(Term.find_by(name: sleep.name)).not_to be_nil 
      end
    end

    context 'with an name that already exists' do
      before { put("/terms/#{sleep.id}",
                    params:  { name: stress.name },
                    headers: { accept:        'application/json',
                               authorization: sleep.user.token }) }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns an error message' do
        expect(json).not_to       be_empty
        expect(json['errors']).to match_array(['Name has already been taken'])
      end

      it 'does not update the term' do
        expect(Term.find_by(name: sleep.name)).not_to be_nil 
      end
    end

    context 'as an user that does not own the term' do
      before { put("/terms/#{sleep.id}",
                    params:  { name: 'Exercise' },
                    headers: { accept:        'application/json',
                               authorization: health.user.token }) }

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns an error message' do
        expect(json).not_to       be_empty
        expect(json['errors']).to match_array(['You are not authorized to perform this action'])
      end

      it 'does not update the term' do
        expect(Term.find_by(name: 'Exercise')).to be_nil 
      end
    end

    context 'without JWT token' do
      before { put("/terms/#{sleep.id}",
                    params:  { name: 'Exercise' },
                    headers: { accept: 'application/json' }) }

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns an error message' do
        expect(json).not_to       be_empty
        expect(json['errors']).to match_array(['You are not authorized to perform this action'])
      end

      it 'does not update the term' do
        expect(Term.find_by(name: 'Exercise')).to be_nil 
      end
    end
  end

  # DELETE /terms/:id
  # ############################################################

  describe 'DELETE /terms/:id' do

    context 'when it is a root term' do
      before { delete("/terms/#{health.id}",
                      headers: { accept:        'application/json',
                                 authorization: health.user.token }) }

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'deletes the whole brainstorming tree' do
        expect(Term.count).to eq(0)
      end
    end

    context 'as an user that does not own the term' do
      before { delete("/terms/#{health.id}",
                      headers: { accept:        'application/json',
                                 authorization: sleep.user.token }) }

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns an error message' do
        expect(json).not_to       be_empty
        expect(json['errors']).to match_array(['You are not authorized to perform this action'])
      end

      it 'does not delete the brainstorming tree' do
        expect(Term.count).to eq(3)
      end
    end

    context 'without JWT token' do
      before { delete("/terms/#{health.id}",
                      headers: { accept: 'application/json' }) }

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns an error message' do
        expect(json).not_to       be_empty
        expect(json['errors']).to match_array(['You are not authorized to perform this action'])
      end

      it 'does not delete the brainstorming tree' do
        expect(Term.count).to eq(3)
      end
    end
  end
end
