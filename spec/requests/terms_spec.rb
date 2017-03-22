require 'rails_helper'

RSpec.describe 'Brainstorm API', type: :request do
  let!(:health)       { create(:term, name: 'Health') }
  let!(:sleep)        { create(:term, name: 'Sleep', parent: health) }
  let!(:stress)       { create(:term, name: 'Stress', parent: health) }

  # GET /
  # ############################################################

  describe 'GET /' do

    context 'when the user is authenticated' do
      before { get_terms(health.user.token) }

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns a list of root terms' do
        expect(json).not_to                  be_empty
        expect(json.size).to                 eq(1)
        expect(json[0]['id']).to             eq(health.id)
        expect(json[0]['name']).to           eq(health.name)
        expect(json[0]['owned_by']).to       eq(health.user.username)
        expect(json[0]['created_at']).not_to be_empty
        expect(json[0]['updated_at']).not_to be_empty
      end
    end

    context 'when the user is not authenticated' do
      before { get_terms }

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns a not authorized message' do
        expect(json).not_to       be_empty
        expect(json['errors']).to match_array(['You are not authorized to perform this action'])
      end
    end
  end

  # GET /terms/:id
  # ############################################################

  describe 'GET /terms/:id' do

    context 'when it is a root term' do
      before { get_term(health, health.user.token) }

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns the tree' do
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

    context 'when it is a child term' do
      before { get_term(sleep, health.user.token) }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a could not be found message' do
        expect(json).not_to       be_empty
        expect(json['errors']).to match_array(["Couldn't find Term with 'id'=#{sleep.id} [WHERE `terms`.`ancestry` IS NULL]"])
      end
    end

    context 'when the user is not authenticated' do
      before { get_term(health) }

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns a not authorized message' do
        expect(json).not_to       be_empty
        expect(json['errors']).to match_array(['You are not authorized to perform this action'])
      end
    end
  end

  # POST /terms
  # ############################################################

  describe 'POST /terms' do

    context 'when the name is valid' do
      before { post_term('Climbing', health.user.token) }

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

      it 'persists the root term' do
        expect(Term.roots.find_by(name: 'Climbing')).not_to be_nil
      end
    end

    context 'when the name is empty' do
      before { post_term('', health.user.token) }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a name can not be blank message' do
        expect(json).not_to       be_empty
        expect(json['errors']).to match_array(["Name can't be blank"])
      end

      it 'does not persists the term' do
        expect(Term.roots.find_by(name: '')).to be_nil
      end
    end

    context 'when the name has 51 characters' do
      before { post_term(Faker::Lorem.characters(51), health.user.token) }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a name is too long message' do
        expect(json).not_to       be_empty
        expect(json['errors']).to match_array(['Name is too long (maximum is 50 characters)'])
      end

      it 'does not persists the term' do
        expect(Term.roots.count).to be(1)
      end
    end

    context 'when the name already exists' do
      before { post_term(health.name, health.user.token) }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a name already exists message' do
        expect(json).not_to       be_empty
        expect(json['errors']).to match_array(['Name has already been taken'])
      end

      it 'does not persists the term' do
        expect(Term.roots.count).to be(1)
      end
    end

    context 'when the user is not authenticated' do
      before { post_term('Climbing') }

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns a not authorized message' do
        expect(json).not_to       be_empty
        expect(json['errors']).to match_array(['You are not authorized to perform this action'])
      end

      it 'does not persists the term' do
        expect(Term.roots.find_by(name: 'Climbing')).to be_nil
      end
    end
  end

  # POST /terms?parent_id=:id
  # ############################################################

  describe 'POST /terms?parent_id=:id' do

    context 'when the name is valid' do
      before { post_term('Climbing', health.user.token, health.id) }

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

      it 'persists the term' do
        expect(health.children.find_by(name: 'Climbing')).not_to be_nil 
      end
    end

    context 'when the parent id does not exist' do
      before { post_term('Climbing', health.user.token, 0) }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(json).not_to       be_empty
        expect(json['errors']).to match_array(["Couldn't find Term with 'id'=0"])
      end

      it 'does not persists the term' do
        expect(Term.find_by(name: 'Climbing')).to be_nil 
      end
    end
  end

  # PUT /terms/:id
  # ############################################################

  describe 'PUT /terms/:id' do

    context 'when the name is valid' do
      before { put_term(sleep.id, 'Exercise', sleep.user.token) }

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns the updated tree' do
        expect(json).not_to               be_empty
        expect(json['id']).to             eq(sleep.id)
        expect(json['name']).to           eq('Exercise')
        expect(json['owned_by']).to       eq(sleep.user.username)
        expect(json['created_at']).not_to be_empty
        expect(json['updated_at']).not_to be_empty
        expect(json['children']).to       be_empty
      end

      it 'persists the update' do
        expect(Term.find_by(name: 'Exercise')).not_to be_nil 
      end
    end

    context 'when the name is empty' do
      before { put_term(sleep.id, '', sleep.user.token) }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a name can not be blank message' do
        expect(json).not_to       be_empty
        expect(json['errors']).to match_array(["Name can't be blank"])
      end

      it 'does not persists the update' do
        expect(Term.find_by(name: sleep.name)).not_to be_nil 
      end
    end

    context 'when the name has 51 characters' do
      before { put_term(sleep.id, Faker::Lorem.characters(51), sleep.user.token) }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a name is too long message' do
        expect(json).not_to       be_empty
        expect(json['errors']).to match_array(['Name is too long (maximum is 50 characters)'])
      end

      it 'does not persists the update' do
        expect(Term.find_by(name: sleep.name)).not_to be_nil 
      end
    end

    context 'when the name already exists' do
      before { put_term(sleep.id, stress.name, sleep.user.token) }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a name already exists message' do
        expect(json).not_to       be_empty
        expect(json['errors']).to match_array(['Name has already been taken'])
      end

      it 'does not persists the update' do
        expect(Term.find_by(name: sleep.name)).not_to be_nil 
      end
    end

    context 'when the user does not own it' do
      before { put_term(sleep.id, 'Exercise', health.user.token) }

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns a not authorized message' do
        expect(json).not_to       be_empty
        expect(json['errors']).to match_array(['You are not authorized to perform this action'])
      end

      it 'does not persists the update' do
        expect(Term.find_by(name: 'Exercise')).to be_nil 
      end
    end

    context 'when it does not exist' do
      before { put_term(0, 'Exercise', sleep.user.token) }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(json).not_to       be_empty
        expect(json['errors']).to match_array(["Couldn't find Term with 'id'=0"])
      end

      it 'does not persists the update' do
        expect(Term.find_by(name: 'Exercise')).to be_nil 
      end
    end

    context 'when the user is not authenticated' do
      before { put_term(sleep.id, 'Exercise') }

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns a not authorized message' do
        expect(json).not_to       be_empty
        expect(json['errors']).to match_array(['You are not authorized to perform this action'])
      end

      it 'does not persists the update' do
        expect(Term.find_by(name: 'Exercise')).to be_nil 
      end
    end
  end

  # DELETE /terms/:id
  # ############################################################

  describe 'DELETE /terms/:id' do

    context 'when it is a root term' do
      before { delete_term(health.id, health.user.token) }

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'deletes the tree' do
        expect(Term.count).to eq(0)
      end
    end

    context 'when the user does not own it' do
      before { delete_term(health.id, sleep.user.token) }

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns a not authorized message' do
        expect(json).not_to       be_empty
        expect(json['errors']).to match_array(['You are not authorized to perform this action'])
      end

      it 'does not delete the tree' do
        expect(Term.count).to eq(3)
      end
    end

    context 'when it does not exist' do
      before { delete_term(0, health.user.token) }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a could not find message' do
        expect(json).not_to       be_empty
        expect(json['errors']).to match_array(["Couldn't find Term with 'id'=0"])
      end

      it 'does not delete a tree' do
        expect(Term.count).to eq(3)
      end
    end

    context 'when the user is not authenticated' do
      before { delete_term(health.id) }

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns a not authorized message' do
        expect(json).not_to       be_empty
        expect(json['errors']).to match_array(['You are not authorized to perform this action'])
      end

      it 'does not delete the tree' do
        expect(Term.count).to eq(3)
      end
    end
  end
end
