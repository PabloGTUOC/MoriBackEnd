# app/models/user_data.rb
class UserData
  include Mongoid::Document
  include Mongoid::Timestamps

  field :user_id, type: String
  field :dob, type: Date
  field :gender, type: String
  field :height, type: Integer
  field :weight, type: Integer
  field :trainingFrequency, type: Integer
  field :smoker, type: Boolean, default: false
  field :drinker, type: Boolean, default: false
  field :country_code, type: String

  validates :user_id, presence: true
  validates :dob, presence: true
  validates :gender, presence: true
  validates :height, presence: true
  validates :weight, presence: true
  validates :trainingFrequency, presence: true
  validates :country_code, presence: true

  # Optional: index user_id for faster queries
  index({ user_id: 1, date: 1 }, { unique: false, background: true })
end
