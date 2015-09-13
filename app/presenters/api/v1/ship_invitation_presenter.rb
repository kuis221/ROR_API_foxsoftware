class Api::V1::ShipInvitationPresenter < Api::V1::JsonPresenter
  # http://rubendiazjorge.me/2015/03/23/faster-rails-json-responses-removing-jbuilder-and-view-rendering/

  def self.minimal_hash(ship_invitation, current_user, object_type)
    hash = %w(id shipment_id invitee_email invitee_id status)
    node = hash_for(ship_invitation, hash)
    node
  end

end
