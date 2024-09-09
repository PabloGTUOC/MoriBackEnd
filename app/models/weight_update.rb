class WeightUpdate
  include Mongoid::Document

  field :user_id, type: String
  field :weight, type: Float
  field :date, type: Date

  validates :user_id, presence: true
  validates :weight, presence: true
  validates :date, presence: true

  # Optional: index user_id for faster queries
  index({ user_id: 1, date: 1 }, { unique: false, background: true })

end
