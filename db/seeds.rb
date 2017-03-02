philipp = User.create! username: 'philipp', password: 'secret', password_confirmation: 'secret' 
rene    = User.create! username: 'rene',    password: 'secret', password_confirmation: 'secret' 

philipp.terms.create! name: 'Health'

[{user: philipp, parent: 'Health',   children: %w{Sleep Stress Exercise Help? Diet}},
 {user: rene,    parent: 'Sleep',    children: ['33% of your life', 'Insomnia Tips', 'Insomnia Consequences']},
 {user: philipp, parent: 'Stress',   children: %w{Causes Solutions Effects}},
 {user: rene,    parent: 'Exercise', children: ['Warm up', 'Aerobic', 'Toning/Strenght', 'Stretching']},
 {user: philipp, parent: 'Help?',    children: ['Doctor', 'Dietician', 'Nutrition Aust']},
 {user: rene,    parent: 'Diet',     children: ['Fruit', 'Vege', 'Breads & Cereals']}].each do |h|

  parent = Term.find_by! name: h[:parent]

  h[:children].each do |child|
  	parent.children.create! name: child, user: h[:user]
  end
end
