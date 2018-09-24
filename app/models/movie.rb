class Movie < ActiveRecord::Base
	def self.get_appropriate_rating
		return ['G','PG','PG-13','R']
	end
end