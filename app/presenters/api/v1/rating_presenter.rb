class Api::V1::RatingPresenter < Api::V1::JsonPresenter
  # http://rubendiazjorge.me/2015/03/23/faster-rails-json-responses-removing-jbuilder-and-view-rendering/

  def self.minimal_hash(rating, current_user, object_type)
    hash = %w(id pick_on_time delivery_on_time tracking_updated had_claims will_recommend created_at)
    node = hash_for(rating, hash)
    node
  end

end
