class ApplicationPolicy

  include Pundit::Serializer

  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    scope.exists?
  end

  def show?
    scope.where(id: record.id).exists?
  end

  def create?
    user.is_of_role? :admin
  end

  def new?
    create?
  end

  def update?
    user.is_of_role? :admin
  end

  def edit?
    update?
  end

  def destroy?
    user.is_of_role? :admin
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

end

