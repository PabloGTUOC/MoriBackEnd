class Training
  include Mongoid::Document

  field :user_id, type: String
  field :date, type: Date
  field :weight, type: Float
  field :training, type: String

  # Optional: index user_id for faster queries
  index({ user_id: 1, date: 1 }, { unique: false, background: true })

end
