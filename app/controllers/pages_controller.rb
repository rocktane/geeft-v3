class PagesController < ApplicationController
	def home
		@user = current_user
		if !current_user.nil?
			@email = current_user.email
		end
	end
end
