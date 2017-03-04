json.(term, :id, :name)

json.owned_by   @users[term.user_id].first.username
json.created_at term.created_at.to_s(:db)
json.updated_at term.updated_at.to_s(:db)

json.children(children) do |parent, children|
  json.partial! 'term', locals: { term: parent, children: children }
end
