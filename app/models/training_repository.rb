# app/models/training_repository.rb
class TrainingRepository
  include Mongoid::Document

  store_in collection: "training_repository"  # Explicitly set the collection name

  field :training_name, type: String
  field :description, type: String
  field :calories, type: Integer
  field :duration, type: Integer
  field :type, type: String
end