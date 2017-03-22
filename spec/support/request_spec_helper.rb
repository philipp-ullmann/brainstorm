module RequestSpecHelper
  def json
    JSON.parse response.body
  end

  def login_with(username, password)
    post('/login',
         params:  { username: username,
                    password: password },
         headers: { accept: 'application/json' })
  end 

  def register_with(username, password, password_confirmation)
    post('/register',
         params:  { username:              username,
                    password:              password,
                    password_confirmation: password_confirmation },
         headers: { accept: 'application/json' })
  end

  def get_terms(token=nil)
    get('/', headers: { accept:        'application/json',
                        authorization: token })
  end

  def get_term(term, token=nil)
    get("/terms/#{term.id}",
        headers: { accept:        'application/json',
                   authorization: token })
  end

  def post_term(name, token=nil, parent_id=nil)
    path = parent_id ? "/terms?parent_id=#{parent_id}" : '/terms'

    post(path,
         params:  { name: name },
         headers: { accept:        'application/json',
                    authorization: token })
  end

  def put_term(id, name, token=nil)
    put("/terms/#{id}",
        params:  { name: name },
        headers: { accept:        'application/json',
                   authorization: token })
  end

  def delete_term(id, token=nil)
    delete("/terms/#{id}",
           headers: { accept:        'application/json',
                      authorization: token })
  end
end
