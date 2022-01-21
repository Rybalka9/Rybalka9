# # frozen_string_literal: true
#
class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, User

    if user.present?
      can(:manage, :all) and return if user.admin?
      can :update, User, id: user.id
      can :read, Room
      can :create, Room# unless Room.
      can :destroy, Room, owner: user
    else
      can :create, User
    end
  end
end
