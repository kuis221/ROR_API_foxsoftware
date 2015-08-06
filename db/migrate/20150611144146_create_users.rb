class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email, :first_name, :last_name, :about, :avatar
      t.inet :ip
      t.timestamps null: false
    end
    add_index :users, :email, unique: true
  end
end
