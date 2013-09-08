class Api::V1::Clouds::BansController < Api::V1Controller

  before_filter :fetch_cloud

  # Fetches all bans for specified cloud.
  #
  #   cloud_id    - Id of the jurisdiction to what this cloud belongs
  #   offender_id - Id of what offender to filter the result by
  #   enforcer_id - Id of what enforcer to filter the result by
  #
  # Returns a Bans collection
  def index

    @bans = @cloud.bans.where(
      params.select { |k,v| [:offender_id,:enforcer_id].include?(k.to_sym) }
    ).order_by(due: :desc)

    render status: 200
  end

  # Creates a new ban for a user on the Cloud.
  #
  #   cloud_id    - Id of the jurisdiction to what this cloud belongs
  #   offender_id - Id of the user receiving the ban.
  #   ban         - A Hash with parameters to be passed to the ban.
  #                   :due - Set the date to which the ban will last
  #                   :reason - 1 to 140 characters why the user deserves the ban
  #
  # Returns a newly created Ban resource
  def create

    @offender = User.find(params[:offender_id])
    @enforcer = current_user

    @ban = @cloud.bans.find_or_initialize_by(offender: @offender)
    @ban.write_attributes(params[:ban])
    @ban.enforcer ||= @enforcer

    if authorize_create(current_user,@ban)
      if @ban.save
        render status: 200
        set_flash_message message: "Your target was sent to the moon.", title: "TO THE MOON!"
      else
        set_flash_message message: "You used the wrong kind of magic and the canon broke.", title: "Moon canon malfunction"
        build_errors_from_model @ban
        render status: 422
      end
    else
      set_flash_message message: "Only supreme rulers are authorized to operate the moon-canon.", title: "No banana bag?"
      build_errors_from_model @ban
      render status: 401
    end

  end

  # Updates a ban for a user on a Cloud. You can use this endpoint
  # to prolong or shorten the due date of the ban.
  #
  #   cloud_id - Id of the jurisdiction to what this cloud belongs
  #   id       - Id of the ban to be updated
  #   ban      - A Hash with parameters to be passed to the ban.
  #               :due - Set the date to which the ban will last
  #               :revoke - If this Boolan is set the Ban will no longer be in effect
  #
  # Returns an updated Ban resource
  def update

    @ban = @cloud.bans.find(params[:id])
    @ban.assign_attributes(params[:ban])

    if authorize_update(current_user,@ban)
      if @ban.save
        render status: 200
      else
        set_flash_message message: "You used the wrong kind of magic and the canon broke.", title: "Moon canon malfunction"
        build_errors_from_model @ban
        render status: 422
      end
    else
      set_flash_message message: "Only supreme rulers are authorized to operate the moon-canon.", title: "No banana bag?"
      build_errors_from_model @ban
      render status: 401
    end
  end

private

  # Fetch and authorize viewing of said cloud.
  # Returns a Cloud model instance if one is found.
  def fetch_cloud
    @cloud ||= Cloud.find(params[:cloud_id])
    authorize @cloud, :show?
  end

  def authorize_create(user,ban)
    i_am_a_moderator        = ban.jurisdiction.moderator_ids.include?(user.id)
    not_prosecuting_myself  = ban.offender.id != user.id
    offender_was_there      = ban.jurisdiction.user_ids.include?(ban.offender.id)

    (i_am_a_moderator || offender_was_there) && not_prosecuting_myself
  end

  def authorize_update(user,ban)
    authorize_create(user,ban)
  end

end
