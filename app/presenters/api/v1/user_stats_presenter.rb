class Api::V1::UserStatsPresenter < Api::V1::JsonPresenter

  # http://rubendiazjorge.me/2015/03/23/faster-rails-json-responses-removing-jbuilder-and-view-rendering/
  def self.minimal_hash(user, current_user)
    json = {
        role: user.main_role,
        created_at: user.created_at,
        last_online: user.last_sign_in_at
    }
    if user.main_role == :carrier
      json[:shipments] = {done_shipments: user.involved_shipments.with_status(:completed).count}
    elsif user.main_role == :shipper
      json[:shipments] = {on_auction: user.shipments.active.count, done_shipments: user.shipments.with_status(:completed).count }
    else
      raise 'NO ROLE FOR STATS PAGE'
    end
    json
  end

end
