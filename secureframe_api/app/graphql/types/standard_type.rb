module Types
  class StandardType < Types::BaseObject
    field :id, ID, null: false
    field :event_name, String, null: false
    field :organization, String, null: true
    field :standard_type, String, null: true
    field :target_time_seconds, Float, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end