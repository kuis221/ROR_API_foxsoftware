class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here.

    # TODO more complex abilities according to who created the resource:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities

  user ||= User.new # guest user (not logged in)

  if user.admin?
    can :manage, :all
    can :access, :rails_admin
    can :dashboard
    # See more user cases for rails_admin: https://github.com/sferik/rails_admin/wiki/CanCan
  elsif user.shipper?
    # can read only his own shipments
    can :manage, Shipment, user_id: user.id
    can :manage, ShipInvitation do |ship_inv|
      user.shipment_ids.include?(ship_inv.shipment_id)
    end
    # And read proposals related to his shipments
    can [:read, :cancel], Proposal do |proposal|
      user.shipment_ids.include?(proposal.shipment_id)
    end
    can :read, Tracking do |tracking|
      user.shipment_ids.include?(tracking.shipment_id)
    end
    can [:read, :create, :update], ShipmentFeedback, user_id: user.id
  elsif user.carrier?
    # can manage - include reject but not cancel
    can :manage, Proposal, user_id: user.id
    cannot :cancel, Proposal
    can :read, Shipment
    can :manage, Tracking, user_id: user.id
  elsif user.has_role?(:user) # both shipper and carrier can manage their address_infos and shipment_feedbacks
    can :manage, AddressInfo, user_id: user.id
  else
    # Unregistered anonym user, fuck off, just fuck off.
  end

    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
  end
end
