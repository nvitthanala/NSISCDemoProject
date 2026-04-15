module Types
  class RaceResultType < Types::BaseObject
    field :id, ID, null: false
    field :athlete_id, Integer, null: false
    field :event_name, String, null: false
    field :time_seconds, Float, null: false
    field :date_swum, GraphQL::Types::ISO8601Date, null: true
    field :round, String, null: true
    field :placement, Integer, null: true
    field :made_a_final, Boolean, null: true
    field :made_b_final, Boolean, null: true
    field :ncaa_status, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end