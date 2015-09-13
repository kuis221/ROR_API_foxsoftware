class AddAltEmailToUser < ActiveRecord::Migration
  def change
    add_column :users, :alt_email, :string
  end
end
