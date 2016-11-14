class UserResource < BaseResource
  PRIVATE_FIELDS = %i[email password].freeze

  attributes :name, :past_names, :about, :bio, :about_formatted, :location,
    :website, :waifu_or_husbando, :to_follow, :followers_count, :created_at,
    :following_count, :onboarded, :life_spent_on_anime, :birthday, :gender,
    :facebook_id, :updated_at, :comments_count, :favorites_count,
    :likes_given_count, :likes_received_count, :posts_count, :ratings_count
  attributes :avatar, :cover_image, format: :attachment
  attributes(*PRIVATE_FIELDS)

  has_one :waifu
  has_many :followers
  has_many :following
  has_many :blocks
  has_many :linked_profiles

  filter :name, apply: -> (records, value, _o) { records.by_name(value.first) }
  filter :self, apply: -> (records, _v, options) {
    current_user = options[:context][:current_user]
    records.where(id: current_user&.id) || User.none
  }

  query :query,
    mode: :query,
    apply: -> (values, _ctx) {
      {
        multi_match: {
          fields: %w[name past_names],
          query: values.join(' '),
          fuzziness: 2,
          max_expansions: 15,
          prefix_length: 1
        }
      }
    }

  def fetchable_fields
    if current_user == _model
      super
    else
      super - PRIVATE_FIELDS
    end
  end
end
