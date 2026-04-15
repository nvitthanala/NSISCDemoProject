class Athlete < ApplicationRecord
  has_many :race_results, dependent: :destroy
end