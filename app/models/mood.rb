# frozen_string_literal: true

class Mood
  include Mongoid::Document
  include Mongoid::Timestamps
  field :user_id, type: String
  field :mood, type: String
  field :date, type: Date
end
