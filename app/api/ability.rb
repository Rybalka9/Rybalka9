# # frozen_string_literal: true
#
class Ability
  include CanCan::Ability

  def initialize(user)

  can :read, User

    if user.present?
      can(:manage, :all) and return if user.admin?
      can :update, User, id: user.id
    else
      can :create, User
    end
  end
end
