class CreateFriendships < ActiveRecord::Migration
  def change
    create_table :friendships do |t|
      t.belongs_to :friend, :user
      t.string :type_of
      t.timestamps null: false
    end
    add_index :friendships, :friend_id
    add_index :friendships, :user_id
  end
end
