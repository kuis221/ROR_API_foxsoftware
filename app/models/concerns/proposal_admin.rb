module ProposalAdmin
  extend ActiveSupport::Concern

  included do

    rails_admin do
      list do
        field :id
        field :price
        field :created_at
        field :user
        field :shipment
      end
    end

  end

end