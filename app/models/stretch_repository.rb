# frozen_string_literal: true

class StretchRepository
  include Mongoid::Document

  store_in collection: "stretch_repository"

  field :stretch_name, type: String
  field :description, type: String
  field :video_link, type: String  # Field to store the YouTube video link
end