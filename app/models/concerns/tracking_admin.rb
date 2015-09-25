module TrackingAdmin
  extend ActiveSupport::Concern

  included do

    rails_admin do
      exclude_fields :updated_at
      list do
        field :shipment
        field :user
        field :location do
          pretty_value do
            bindings[:view].render partial: '/api/v1/rails_admin/link_to_gmap', locals: {tracking: bindings[:object], add_text: false}
          end
        end
        field :checkpoint_time
        field :created_at
      end
    end

  end

end