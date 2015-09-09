class Api::V1::UserPresenter < Api::V1::JsonPresenter

  # http://rubendiazjorge.me/2015/03/23/faster-rails-json-responses-removing-jbuilder-and-view-rendering/
  def self.minimal_hash(user, current_user, object_type)
    hash_for(user, %w(id first_name last_name email))
  end

end
