class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.with_options null: false do |o|
        o.string :username, unique: true
        o.string :password_digest
        o.timestamps
      end
    end
  end
end
