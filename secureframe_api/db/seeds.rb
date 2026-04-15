puts "Wiping database clean..."
RaceResult.destroy_all
Standard.destroy_all
Athlete.destroy_all

# --- HELPER METHODS ---
# Helper to convert "1:46.74" or "20.22" into flat seconds for the database
def parse_time(time_str)
  parts = time_str.to_s.split(':')
  if parts.length == 2
    parts[0].to_i * 60 + parts[1].to_f
  else
    parts[0].to_f
  end
end

# Dynamically grades the status based on the database standards
def grade_time(event_name, time_seconds)
  a_cut = Standard.find_by(event_name: event_name, standard_type: 'A-Cut')&.target_time_seconds || 999
  b_cut = Standard.find_by(event_name: event_name, standard_type: 'B-Cut')&.target_time_seconds || 999

  if time_seconds <= a_cut
    'A-Cut'
  elsif time_seconds <= b_cut
    'B-Cut'
  else
    'None'
  end
end


# --- 1. SEED STANDARDS ---
puts "Loading 2026 NCAA D2 Men's Standards..."

standards = [
  { event_name: '50Y Free', standard_type: 'A-Cut', target: '19.39' },
  { event_name: '50Y Free', standard_type: 'B-Cut', target: '20.36' },
  { event_name: '100Y Free', standard_type: 'A-Cut', target: '43.08' },
  { event_name: '100Y Free', standard_type: 'B-Cut', target: '45.23' },
  { event_name: '200Y Free', standard_type: 'A-Cut', target: '1:34.74' },
  { event_name: '200Y Free', standard_type: 'B-Cut', target: '1:39.48' },
  { event_name: '500Y Free', standard_type: 'A-Cut', target: '4:19.98' },
  { event_name: '500Y Free', standard_type: 'B-Cut', target: '4:32.98' },
  { event_name: '1000Y Free', standard_type: 'A-Cut', target: '8:58.94' },
  { event_name: '1000Y Free', standard_type: 'B-Cut', target: '9:25.89' },
  { event_name: '1650Y Free', standard_type: 'A-Cut', target: '15:11.41' },
  { event_name: '1650Y Free', standard_type: 'B-Cut', target: '15:56.98' },
  { event_name: '100Y Back', standard_type: 'A-Cut', target: '46.32' },
  { event_name: '100Y Back', standard_type: 'B-Cut', target: '48.64' },
  { event_name: '200Y Back', standard_type: 'A-Cut', target: '1:42.18' },
  { event_name: '200Y Back', standard_type: 'B-Cut', target: '1:47.29' },
  { event_name: '100Y Breast', standard_type: 'A-Cut', target: '52.60' },
  { event_name: '100Y Breast', standard_type: 'B-Cut', target: '55.23' },
  { event_name: '200Y Breast', standard_type: 'A-Cut', target: '1:55.12' },
  { event_name: '200Y Breast', standard_type: 'B-Cut', target: '2:00.87' },
  { event_name: '100Y Fly', standard_type: 'A-Cut', target: '46.17' },
  { event_name: '100Y Fly', standard_type: 'B-Cut', target: '48.48' },
  { event_name: '200Y Fly', standard_type: 'A-Cut', target: '1:44.66' },
  { event_name: '200Y Fly', standard_type: 'B-Cut', target: '1:49.89' },
  { event_name: '200Y IM', standard_type: 'A-Cut', target: '1:44.60' },
  { event_name: '200Y IM', standard_type: 'B-Cut', target: '1:49.83' },
  { event_name: '400Y IM', standard_type: 'A-Cut', target: '3:46.91' },
  { event_name: '400Y IM', standard_type: 'B-Cut', target: '3:58.26' }
]

standards.each do |std|
  Standard.create!(
    event_name: std[:event_name],
    organization: 'NCAA D2',
    standard_type: std[:standard_type],
    target_time_seconds: parse_time(std[:target])
  )
end


# --- 2. SEED ATHLETES & RESULTS ---
puts "Loading 2026 Men's Top 16 Roster & Times..."

athletes_data = [
  # --- OUACHITA BAPTIST UNIVERSITY ---
  { first_name: 'Sam', last_name: 'Ragsdell', team: 'Ouachita Baptist University', results: [
    { event: '50Y Free', time: '20.22', round: 'A-Final' },
    { event: '100Y Free', time: '44.45', round: 'A-Final' },
    { event: '200Y Free', time: '1:38.79', round: 'A-Final' },
    { event: '100Y Back', time: '49.58', round: 'A-Final' }
  ]},
  { first_name: 'Ian', last_name: 'Redman', team: 'Ouachita Baptist University', results: [
    { event: '50Y Free', time: '20.55', round: 'A-Final' },
    { event: '100Y Free', time: '44.90', round: 'A-Final' },
    { event: '100Y Back', time: '53.32', round: 'B-Final' },
    { event: '100Y Fly', time: '49.25', round: 'A-Final' }
  ]},
  { first_name: 'James', last_name: 'Savarese', team: 'Ouachita Baptist University', results: [
    { event: '50Y Free', time: '20.79', round: 'A-Final' },
    { event: '100Y Free', time: '45.80', round: 'B-Final' },
    { event: '200Y Free', time: '1:42.93', round: 'A-Final' },
    { event: '100Y Back', time: '52.36', round: 'B-Final' }
  ]},
  { first_name: 'Mikhail', last_name: 'Lymar', team: 'Ouachita Baptist University', results: [
    { event: '50Y Free', time: '20.96', round: 'B-Final' },
    { event: '100Y Back', time: '49.95', round: 'A-Final' },
    { event: '200Y Back', time: '1:50.67', round: 'A-Final' }
  ]},
  { first_name: 'Sparky', last_name: 'Sparks', team: 'Ouachita Baptist University', results: [
    { event: '100Y Back', time: '50.06', round: 'A-Final' },
    { event: '200Y Back', time: '1:51.63', round: 'A-Final' },
    { event: '100Y Fly', time: '49.48', round: 'A-Final' },
    { event: '200Y IM', time: '1:52.19', round: 'A-Final' }
  ]},
  { first_name: 'David', last_name: 'Ware', team: 'Ouachita Baptist University', results: [
    { event: '100Y Back', time: '49.53', round: 'A-Final' },
    { event: '200Y Back', time: '1:53.92', round: 'A-Final' },
    { event: '100Y Fly', time: '49.83', round: 'A-Final' },
    { event: '200Y IM', time: '1:52.03', round: 'B-Final' }
  ]},
  { first_name: 'Vince', last_name: 'Pal', team: 'Ouachita Baptist University', results: [
    { event: '100Y Free', time: '45.43', round: 'A-Final' },
    { event: '200Y Free', time: '1:39.97', round: 'A-Final' },
    { event: '100Y Fly', time: '50.08', round: 'B-Final' },
    { event: '200Y Fly', time: '1:51.62', round: 'A-Final' }
  ]},
  { first_name: 'Colton', last_name: 'Martinez', team: 'Ouachita Baptist University', results: [
    { event: '1000Y Free', time: '9:51.60', round: 'Finals' },
    { event: '100Y Fly', time: '50.13', round: 'B-Final' },
    { event: '200Y Fly', time: '1:50.04', round: 'A-Final' }
  ]},
  { first_name: 'Caston', last_name: 'Feazel', team: 'Ouachita Baptist University', results: [
    { event: '1000Y Free', time: '10:13.37', round: 'Finals' },
    { event: '100Y Fly', time: '52.15', round: 'B-Final' },
    { event: '200Y Fly', time: '1:52.78', round: 'A-Final' }
  ]},
  { first_name: 'Anthony', last_name: 'Paculba', team: 'Ouachita Baptist University', results: [
    { event: '200Y Back', time: '1:50.44', round: 'A-Final' },
    { event: '100Y Breast', time: '57.71', round: 'B-Final' },
    { event: '200Y IM', time: '1:53.09', round: 'B-Final' },
    { event: '400Y IM', time: '4:00.74', round: 'A-Final' }
  ]},
  { first_name: 'Lucas', last_name: 'Cagle', team: 'Ouachita Baptist University', results: [
    { event: '100Y Breast', time: '57.15', round: 'B-Final' },
    { event: '200Y Breast', time: '2:02.54', round: 'A-Final' },
    { event: '200Y IM', time: '1:53.68', round: 'B-Final' },
    { event: '400Y IM', time: '4:05.95', round: 'A-Final' }
  ]},
  { first_name: 'Stefan', last_name: 'Duca', team: 'Ouachita Baptist University', results: [
    { event: '200Y Free', time: '1:37.83', round: 'A-Final' },
    { event: '500Y Free', time: '4:30.53', round: 'A-Final' },
    { event: '1000Y Free', time: '9:32.25', round: 'Finals' }
  ]},
  { first_name: 'Tyler', last_name: 'Andruss', team: 'Ouachita Baptist University', results: [
    { event: '200Y Free', time: '1:38.95', round: 'A-Final' },
    { event: '500Y Free', time: '4:27.12', round: 'A-Final' },
    { event: '1000Y Free', time: '9:19.14', round: 'Finals' },
    { event: '1650Y Free', time: '15:46.23', round: 'Finals' }
  ]},
  { first_name: 'Caleb', last_name: 'Guthrie', team: 'Ouachita Baptist University', results: [
    { event: '1000Y Free', time: '9:59.57', round: 'Finals' },
    { event: '200Y Fly', time: '1:56.45', round: 'B-Final' },
    { event: '400Y IM', time: '4:13.60', round: 'B-Final' }
  ]},
  { first_name: 'Nathan', last_name: 'Wardlow', team: 'Ouachita Baptist University', results: [
    { event: '500Y Free', time: '4:46.76', round: 'B-Final' },
    { event: '1000Y Free', time: '10:00.58', round: 'Finals' },
    { event: '200Y Back', time: '1:52.89', round: 'B-Final' },
    { event: '400Y IM', time: '4:14.58', round: 'B-Final' }
  ]},
  { first_name: 'Justin', last_name: 'Oulette', team: 'Ouachita Baptist University', results: [
    { event: '100Y Breast', time: '55.16', round: 'A-Final' },
    { event: '200Y Breast', time: '2:01.43', round: 'A-Final' },
    { event: '200Y Fly', time: '2:00.72', round: 'B-Final' },
    { event: '400Y IM', time: '4:14.81', round: 'B-Final' }
  ]},

  # --- HENDERSON STATE UNIVERSITY ---
  { first_name: 'Oliver', last_name: 'Pozvai', team: 'Henderson State University', results: [
    { event: '50Y Free', time: '20.28', round: 'A-Final' },
    { event: '100Y Free', time: '44.44', round: 'A-Final' },
    { event: '100Y Back', time: '51.94', round: 'A-Final' }
  ]},
  { first_name: 'Gavin', last_name: 'Kock', team: 'Henderson State University', results: [
    { event: '50Y Free', time: '20.47', round: 'A-Final' },
    { event: '100Y Free', time: '45.52', round: 'B-Final' },
    { event: '100Y Breast', time: '56.81', round: 'A-Final' },
    { event: '100Y Fly', time: '50.31', round: 'A-Final' }
  ]},
  { first_name: 'Tristen', last_name: 'Fergunson', team: 'Henderson State University', results: [
    { event: '50Y Free', time: '20.59', round: 'A-Final' },
    { event: '100Y Free', time: '46.50', round: 'B-Final' },
    { event: '100Y Fly', time: '53.08', round: 'B-Final' }
  ]},
  { first_name: 'Vitor', last_name: 'Sa', team: 'Henderson State University', results: [
    { event: '50Y Free', time: '20.74', round: 'A-Final' },
    { event: '100Y Free', time: '45.90', round: 'A-Final' },
    { event: '100Y Fly', time: '51.15', round: 'B-Final' }
  ]},
  { first_name: 'Scott', last_name: 'Doll', team: 'Henderson State University', results: [
    { event: '50Y Free', time: '20.90', round: 'B-Final' },
    { event: '100Y Free', time: '45.39', round: 'A-Final' },
    { event: '200Y Free', time: '1:45.02', round: 'B-Final' },
    { event: '500Y Free', time: '4:44.38', round: 'B-Final' }
  ]},
  { first_name: 'Colin', last_name: 'Candebat', team: 'Henderson State University', results: [
    { event: '100Y Fly', time: '47.86', round: 'A-Final' },
    { event: '200Y Fly', time: '1:48.47', round: 'A-Final' },
    { event: '200Y IM', time: '1:46.74', round: 'A-Final' }
  ]},
  { first_name: 'Stevie', last_name: 'Balistreri', team: 'Henderson State University', results: [
    { event: '100Y Fly', time: '49.32', round: 'A-Final' },
    { event: '200Y Fly', time: '1:52.33', round: 'A-Final' },
    { event: '200Y IM', time: '1:54.71', round: 'A-Final' }
  ]},
  { first_name: 'Avery', last_name: 'Henke', team: 'Henderson State University', results: [
    { event: '100Y Breast', time: '54.27', round: 'A-Final' },
    { event: '200Y Breast', time: '2:03.44', round: 'A-Final' },
    { event: '100Y Fly', time: '52.61', round: 'A-Final' },
    { event: '200Y IM', time: '1:50.63', round: 'A-Final' }
  ]},
  { first_name: 'Nojus', last_name: 'Skirutis', team: 'Henderson State University', results: [
    { event: '200Y Back', time: '1:49.10', round: 'A-Final' },
    { event: '200Y Fly', time: '1:47.40', round: 'A-Final' },
    { event: '200Y IM', time: '1:48.93', round: 'A-Final' },
    { event: '400Y IM', time: '3:55.11', round: 'A-Final' }
  ]},
  { first_name: 'Hunter', last_name: 'Rytting', team: 'Henderson State University', results: [
    { event: '100Y Back', time: '50.41', round: 'A-Final' },
    { event: '200Y Back', time: '1:48.02', round: 'A-Final' },
    { event: '200Y IM', time: '1:51.18', round: 'A-Final' },
    { event: '400Y IM', time: '3:57.74', round: 'A-Final' }
  ]},
  { first_name: 'Oskar', last_name: 'Cebula', team: 'Henderson State University', results: [
    { event: '100Y Breast', time: '55.45', round: 'A-Final' },
    { event: '200Y Breast', time: '2:04.66', round: 'A-Final' },
    { event: '200Y IM', time: '2:00.57', round: 'A-Final' },
    { event: '400Y IM', time: '4:24.95', round: 'B-Final' }
  ]},
  { first_name: 'Emiliano', last_name: 'Pina', team: 'Henderson State University', results: [
    { event: '200Y Breast', time: '2:13.80', round: 'B-Final' },
    { event: '200Y Fly', time: '1:53.38', round: 'B-Final' },
    { event: '200Y IM', time: '1:54.43', round: 'B-Final' },
    { event: '400Y IM', time: '4:09.28', round: 'A-Final' }
  ]},
  { first_name: 'Alan', last_name: 'Gonzalez Mujica', team: 'Henderson State University', results: [
    { event: '200Y Free', time: '1:41.25', round: 'B-Final' },
    { event: '500Y Free', time: '4:33.77', round: 'A-Final' },
    { event: '1000Y Free', time: '9:34.46', round: 'Finals' }
  ]},
  { first_name: 'Thomas', last_name: 'Landreneau', team: 'Henderson State University', results: [
    { event: '200Y Free', time: '1:44.92', round: 'B-Final' },
    { event: '500Y Free', time: '4:49.12', round: 'A-Final' },
    { event: '1000Y Free', time: '9:37.44', round: 'Finals' }
  ]},
  { first_name: 'Aidan', last_name: 'Eckard', team: 'Henderson State University', results: [
    { event: '100Y Back', time: '51.55', round: 'A-Final' },
    { event: '200Y Back', time: '1:52.55', round: 'B-Final' },
    { event: '400Y IM', time: '4:16.38', round: 'B-Final' }
  ]},
  { first_name: 'Colton', last_name: 'Bennett', team: 'Henderson State University', results: [
    { event: '500Y Free', time: '4:33.41', round: 'A-Final' },
    { event: '1000Y Free', time: '9:26.63', round: 'Finals' },
    { event: '200Y Fly', time: '1:55.26', round: 'A-Final' }
  ]},
  { first_name: 'Bartu', last_name: 'Akin', team: 'Henderson State University', results: [
    { event: '500Y Free', time: '4:43.45', round: 'A-Final' },
    { event: '1000Y Free', time: '9:30.37', round: 'Finals' },
    { event: '1650Y Free', time: '16:00.67', round: 'Finals' },
    { event: '400Y IM', time: '3:58.72', round: 'A-Final' }
  ]},
  { first_name: 'Eli', last_name: 'Westbrook', team: 'Henderson State University', results: [
    { event: '200Y Back', time: '1:52.69', round: 'B-Final' }
  ]},
  { first_name: 'Mark', last_name: 'Eberhard', team: 'Henderson State University', results: [
    { event: '100Y Breast', time: '55.54', round: 'A-Final' },
    { event: '400Y IM', time: '4:53.08', round: 'B-Final' }
  ]},
  { first_name: 'Cam', last_name: 'Mask', team: 'Henderson State University', results: [
    { event: '200Y Breast', time: '2:02.69', round: 'B-Final' }
  ]},
  { first_name: 'Benjamin', last_name: 'Skinner', team: 'Henderson State University', results: [
    { event: '200Y Breast', time: '2:10.99', round: 'B-Final' }
  ]},

  # --- DELTA STATE UNIVERSITY ---
  { first_name: 'Ethan', last_name: 'Baylin', team: 'Delta State University', results: [
    { event: '50Y Free', time: '20.36', round: 'A-Final' },
    { event: '100Y Free', time: '44.03', round: 'A-Final' },
    { event: '100Y Breast', time: '55.39', round: 'A-Final' }
  ]},
  { first_name: 'Lars', last_name: 'Hetzel', team: 'Delta State University', results: [
    { event: '50Y Free', time: '21.03', round: 'B-Final' },
    { event: '100Y Free', time: '45.62', round: 'A-Final' },
    { event: '200Y Free', time: '1:40.49', round: 'B-Final' }
  ]},
  { first_name: 'Sergio', last_name: 'Rodriguez', team: 'Delta State University', results: [
    { event: '50Y Free', time: '21.22', round: 'B-Final' },
    { event: '100Y Free', time: '46.73', round: 'B-Final' },
    { event: '200Y Free', time: '1:46.22', round: 'B-Final' },
    { event: '100Y Breast', time: '59.58', round: 'B-Final' }
  ]},
  { first_name: 'Kostantin', last_name: 'Ilijic', team: 'Delta State University', results: [
    { event: '50Y Free', time: '21.45', round: 'B-Final' },
    { event: '100Y Free', time: '46.98', round: 'B-Final' },
    { event: '200Y Free', time: '1:45.47', round: 'B-Final' },
    { event: '100Y Breast', time: '58.24', round: 'B-Final' }
  ]},
  { first_name: 'Alessandro', last_name: 'Giustolisi', team: 'Delta State University', results: [
    { event: '50Y Free', time: '21.65', round: 'B-Final' },
    { event: '100Y Fly', time: '49.73', round: 'B-Final' }
  ]},
  { first_name: 'Kacper', last_name: 'Mochnal', team: 'Delta State University', results: [
    { event: '200Y Free', time: '1:42.03', round: 'A-Final' },
    { event: '100Y Fly', time: '48.99', round: 'A-Final' },
    { event: '200Y IM', time: '1:53.68', round: 'B-Final' }
  ]},
  { first_name: 'Ashtin', last_name: 'Wallace', team: 'Delta State University', results: [
    { event: '100Y Back', time: '51.78', round: 'B-Final' },
    { event: '200Y Back', time: '1:57.47', round: 'B-Final' },
    { event: '100Y Fly', time: '50.95', round: 'B-Final' }
  ]},
  { first_name: 'Luis', last_name: 'Ploner', team: 'Delta State University', results: [
    { event: '200Y Free', time: '1:46.02', round: 'B-Final' },
    { event: '200Y Back', time: '1:58.67', round: 'B-Final' },
    { event: '100Y Fly', time: '54.52', round: 'B-Final' },
    { event: '200Y Fly', time: '2:05.67', round: 'B-Final' }
  ]},
  { first_name: 'Riley', last_name: 'Oakes', team: 'Delta State University', results: [
    { event: '100Y Back', time: '49.76', round: 'A-Final' },
    { event: '200Y Back', time: '1:48.50', round: 'A-Final' },
    { event: '200Y IM', time: '1:50.37', round: 'A-Final' },
    { event: '400Y IM', time: '3:57.33', round: 'A-Final' }
  ]},
  { first_name: 'Eudald', last_name: 'Tosquella', team: 'Delta State University', results: [
    { event: '100Y Breast', time: '56.77', round: 'B-Final' },
    { event: '200Y Breast', time: '2:01.34', round: 'A-Final' },
    { event: '200Y IM', time: '1:51.79', round: 'B-Final' },
    { event: '400Y IM', time: '4:10.41', round: 'A-Final' }
  ]},
  { first_name: 'Neill', last_name: 'Mauss', team: 'Delta State University', results: [
    { event: '100Y Breast', time: '55.36', round: 'A-Final' },
    { event: '200Y Breast', time: '2:04.32', round: 'A-Final' },
    { event: '200Y IM', time: '1:54.25', round: 'B-Final' },
    { event: '400Y IM', time: '4:09.87', round: 'B-Final' }
  ]},
  { first_name: 'Jacob', last_name: 'Hamblen', team: 'Delta State University', results: [
    { event: '100Y Breast', time: '54.37', round: 'A-Final' },
    { event: '200Y Breast', time: '2:35.14', round: 'B-Final' },
    { event: '200Y IM', time: '2:03.04', round: 'B-Final' }
  ]},
  { first_name: 'Austin', last_name: 'Huffhines', team: 'Delta State University', results: [
    { event: '100Y Free', time: '45.85', round: 'B-Final' },
    { event: '200Y Free', time: '1:38.62', round: 'A-Final' },
    { event: '500Y Free', time: '4:38.12', round: 'A-Final' },
    { event: '1000Y Free', time: '10:00.10', round: 'Finals' }
  ]},
  { first_name: 'Mateus', last_name: 'Franco', team: 'Delta State University', results: [
    { event: '200Y Free', time: '1:40.91', round: 'A-Final' },
    { event: '1000Y Free', time: '9:03.37', round: 'Finals' }
  ]},
  { first_name: 'Adam', last_name: 'Rickert', team: 'Delta State University', results: [
    { event: '1000Y Free', time: '9:38.13', round: 'Finals' }
  ]},
  { first_name: 'Reece', last_name: 'Achord', team: 'Delta State University', results: [
    { event: '100Y Breast', time: '56.73', round: 'B-Final' },
    { event: '200Y Breast', time: '2:04.28', round: 'A-Final' },
    { event: '1000Y Free', time: '10:05.34', round: 'Finals' }
  ]}
]

# Write everything to the database safely
athletes_data.each do |data|
  # Ensures we don't accidentally duplicate a swimmer if the script is modified later
  athlete = Athlete.find_or_create_by!(
    first_name: data[:first_name],
    last_name: data[:last_name]
  ) do |a|
    a.team = data[:team]
    a.active = true
  end

  data[:results].each do |race|
    time_in_seconds = parse_time(race[:time])
    
    # Ensures we don't accidentally log the exact same race result twice
    unless RaceResult.exists?(athlete: athlete, event_name: race[:event], time_seconds: time_in_seconds)
      RaceResult.create!(
        athlete: athlete,
        event_name: race[:event],
        time_seconds: time_in_seconds,
        date_swum: Date.parse('2026-02-21'),
        round: race[:round],
        ncaa_status: grade_time(race[:event], time_in_seconds)
      )
    end
  end
end

puts "Database successfully seeded with #{Athlete.count} athletes and #{RaceResult.count} 2026 NSISC Championship results!"