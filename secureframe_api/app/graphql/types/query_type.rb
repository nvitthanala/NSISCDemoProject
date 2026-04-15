module Types
  class QueryType < Types::BaseObject

    field :athletes, [Types::AthleteType], null: false, description: "Get all athletes"
    def athletes
      Athlete.all
    end

    field :race_results, [Types::RaceResultType], null: false, description: "Get all race results"
    def race_results
      RaceResult.all
    end
  end
end