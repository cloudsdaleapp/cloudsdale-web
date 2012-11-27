extends 'api/v1/clouds/mini'

object @cloud

node(:user_ids) { |cloud| cloud.user_ids.map(&:to_s) }
node(:moderator_ids) { |cloud| cloud.moderator_ids.map(&:to_s) }
