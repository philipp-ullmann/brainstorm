philipp = User.create! username: 'philipp', password: 'secret', password_confirmation: 'secret' 
rene    = User.create! username: 'rene',    password: 'secret', password_confirmation: 'secret' 

health = philipp.terms.create! name: 'Health'

health.create_children_for! %w{Sleep Stress Exercise Help? Diet}, philipp

health.children.find_by!(name: 'Sleep').create_children_for! ['33% of your life', 'Insomnia Tips', 'Insomnia Consequences'], rene

health.children.find_by!(name: 'Stress').create_children_for! %w{Causes Solutions Effects}, philipp

health.children.find_by!(name: 'Exercise').create_children_for! ['Warm up', 'Aerobic', 'Toning/Strenght', 'Stretching'], rene

health.children.find_by!(name: 'Help?').create_children_for! ['Doctor', 'Dietician', 'Nutrition Aust'], philipp

health.children.find_by!(name: 'Diet').create_children_for! ['Fruit', 'Vege', 'Breads & Cereals'], rene
