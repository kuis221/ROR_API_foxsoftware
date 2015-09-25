module FriendshipAdmin
  extend ActiveSupport::Concern

  included do

    rails_admin do
      exclude_fields :updated_at
    end

  end

end