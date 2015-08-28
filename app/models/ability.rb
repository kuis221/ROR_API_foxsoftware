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
  elsif user.client?
    # can read only his own shipments
    can :manage, Shipment, user_id: user.id
    # And read bids related to his shipments
    can :read, Bid do |bid|
      user.shipment_ids.include?(bid.shipment_id)
    end
    can :manage, ShipInvitation, user_id: user.id
  elsif user.carrier?
    # can create bid for invited shipments ?? check with Matt
    can :manage, Bid, user_id: user.id
    can :read, Shipment
  elsif user.has_role?(:user) # both client and carrier can manage their address_infos and shipment_feedbacks
    can :manage, AddressInfo, user_id: user.id
    can [:read, :create, :update], ShipmentFeedback, user_id: user.id
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
