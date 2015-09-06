class McNumUsers < ActiveRecord::Migration
  def change
    add_column :users, :mc_num, :string
  end
end
