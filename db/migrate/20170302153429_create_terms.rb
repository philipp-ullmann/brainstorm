class CreateTerms < ActiveRecord::Migration[5.0]
  def change
    create_table :terms do |t|
      t.with_options null: false do |o|
        o.string :name
        o.references :user, index: true, foreign_key: true
        o.timestamps
      end

      t.string :ancestry, index: true
    end

    add_index :terms, [:name, :ancestry], unique: true
  end
end
