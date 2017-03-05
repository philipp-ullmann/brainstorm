# Brainstorming tree view generation.
class TermTree
  def initialize(root, children, users)
    @root     = root
    @children = children
    @users    = users
  end

  # Builds a brainstorming tree.
  def build
    subtree(@root, @children)
  end

  private

  def subtree(parent, children)
    term = to_map(parent)
    
    children.each do |p, c|
      term[:children] << subtree(p, c)
    end

    term
  end

  def username(term)
    @users[term.user_id].first.username
  end

  def to_map(term)
    { id:         term.id,
      name:       term.name,
      owned_by:   username(term),
      created_at: term.created_at.to_s(:db),
      updated_at: term.updated_at.to_s(:db),
      children:   [] }
  end
end
