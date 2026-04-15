module Mutations
  class CreateRaceResult < BaseMutation
    # These are the inputs we expect React to send us
    argument :athlete_id, ID, required: true
    argument :event_name, String, required: true
    argument :time_seconds, Float, required: true
    argument :round, String, required: true

    # This is what we send back to React after saving
    field :race_result, Types::RaceResultType, null: true
    field :errors, [String], null: false

    def resolve(athlete_id:, event_name:, time_seconds:, round:)
      athlete = Athlete.find(athlete_id)

      # 1. Look up the official standards for this specific event
      a_standard = Standard.find_by(event_name: event_name, standard_type: 'A-Cut')&.target_time_seconds || 999
      b_standard = Standard.find_by(event_name: event_name, standard_type: 'B-Cut')&.target_time_seconds || 999

      # 2. Automatically grade the time
      ncaa_status = 'None'
      if time_seconds <= a_standard
        ncaa_status = 'A-Cut'
      elsif time_seconds <= b_standard
        ncaa_status = 'B-Cut'
      end

      # 3. Build and save the new record
      result = RaceResult.new(
        athlete: athlete,
        event_name: event_name,
        time_seconds: time_seconds,
        date_swum: Date.today,
        round: round,
        ncaa_status: ncaa_status
      )

      if result.save
        { race_result: result, errors: [] }
      else
        { race_result: nil, errors: result.errors.full_messages }
      end
    end
  end
end