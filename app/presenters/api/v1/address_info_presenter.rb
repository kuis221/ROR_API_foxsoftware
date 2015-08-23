class Api::V1::AddressInfoPresenter < Api::V1::JsonPresenter

  # http://rubendiazjorge.me/2015/03/23/faster-rails-json-responses-removing-jbuilder-and-view-rendering/
  def self.minimal_hash(address_info, current_user)
    hash = %w(id type contact_name city zip_code address1 address2 state appointment)
    hash_for(address_info, hash)
  end

end