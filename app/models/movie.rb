class Movie < ActiveRecord::Base
  def self.all_ratings
    Movie.uniq.order(:rating).pluck(:rating)
  end
end
