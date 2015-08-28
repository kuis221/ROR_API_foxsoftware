class Api::V1::FriendshipPresenter < Api::V1::JsonPresenter
  # http://rubendiazjorge.me/2015/03/23/faster-rails-json-responses-removing-jbuilder-and-view-rendering/

  def self.minimal_hash(friendship, current_user)
    hash = %w(id type_of created_at)
    node = hash_for(friendship, hash)
    friend = friendship.friend
    node[:friend] = hash_for(friend, %w(id name))
    node
  end

end
