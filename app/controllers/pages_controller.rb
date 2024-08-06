class PagesController < ApplicationController
	def home
		if current_user
			@email = current_user.email
		end
	end
end
