class Api::V1::TrackingPresenter < Api::V1::JsonPresenter

  # http://rubendiazjorge.me/2015/03/23/faster-rails-json-responses-removing-jbuilder-and-view-rendering/
  def self.minimal_hash(tracking, current_user, object_type)
    attrs = %w(id location notes checkpoint_time shipment_id)
    json = hash_for(tracking, attrs)
    json
  end

end
