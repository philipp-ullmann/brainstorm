json.array! @terms do |term|
  json.(term, :id, :name)

  json.owned_by   term.user.username
  json.created_at term.created_at.to_s(:db)
  json.updated_at term.updated_at.to_s(:db)
end
