module ShipmentAdmin
  extend ActiveSupport::Concern

  included do

    rails_admin do
      list do
        field :id
        field :price
        field :status do
          pretty_value do
            shipment = bindings[:object]
            if shipment.state == :in_transit && shipment.trackings.last
              help 'When in transit - will try to open last tracking location'
              bindings[:view].render partial: '/api/v1/rails_admin/link_to_gmap', locals: {tracking: shipment.trackings.last, add_text: shipment.state}
              # pretty_value do
              #
              # end
            else
              shipment.state
            end
          end
        end
        field :user
        field :proposals
        field :active
        # field :some_field do
        #   visible do
        #     bindings[:view]._current_user.roles.include?(:some_role)
        #   end
        # end
      end
      edit do
        exclude_fields :secret, :aasm_state, :rating, :roles, :updated_at, :created_at
      end
      show do
        exclude_fields :secret, :roles
      end
    end

  end

end