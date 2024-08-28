class GiftsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client, only: [:create]
	before_action :check_user, only: [:show]
	# before_action :check_if_event, only: [:show]

  def index
    @gifts = Gift.all
  end

  def show
    @user = current_user
    @gift = Gift.find(params[:id])
    @event = @gift.event_id ? Event.find(@gift.event_id) : Event.new
		if @gift.generated_list.class == Array
			@gifts_to_display = @gift.generated_list.take(5)
		else
			redirect_to "/422.html"
		end
		# @domain = request.host_with_port

    respond_to do |format|
      format.html
      format.json { render json: @gift }
    end
  end

  def new
    @event = params[:event_id] ? Event.find(params[:event_id]) : Event.new
    @gift = Gift.new
    # @gift.event = @event
  end

	def create
		@gift = Gift.new(gift_params)
		# @event = params[:event_id] ? Event.find(params[:event_id]) : Event.new
		# @gift.event = @event
		@event = Event.new
		@gift.user = current_user
		@gift.interests = @gift.interests.compact_blank

		@gift.generated_list = generate_list(@gift)

		respond_to do |format|
			if @gift.save
				format.json { render json: @gift,
														status: :created }
			else
				format.json { render json: @gift.errors, status: :unprocessable_entity }
			end
		end
	end

  def update
    @gift = Gift.find(params[:id])
    comment = params[:comment]
    @gift.update(generated_list: @gift.update_gifts($client, comment,
		@gift.interests).split(/\d+\.\s+/).map(&:strip).compact_blank)
		respond_to do |format|
				if @gift.save
					@gift.update(comment: true)
						format.json { render json: @gift,
																status: :created }
				else
						format.json { render json: @gift.errors, status: :unprocessable_entity }
				end
		end
  end

  def updatelist
    @gift = Gift.find(params[:id])
		@event = Event.find(params[:event_id]) if params[:event_id]
		if @event
			@gift.event = @event
			redirect_url = event_path(@event)
		else
			redirect_url = new_gift_event_path(@gift)
		end
    @gift.generated_list = [params[:gift][:generated_list]].flatten
		respond_to do |format|
    	if @gift.save
				format.json { render json: { gift: @gift, success: true, redirect_url: redirect_url } }
			else
				format.json { render json: { gift: @gift, success: false, redirect_url: redirect_url, status: :unprocessable_entity } }
			end
		end
  end

def deleteindex
  @gift = Gift.find(params[:id])
  index = params[:index].to_i
  @gift.generated_list.delete_at(index)

  if @gift.generated_list.empty?
    if @gift.destroy
      render json: { success: true, notice: "Cadeau supprimé avec succès.", gift_destroyed: true }
    else
      render json: { success: false, notice: "Erreur lors de la suppression du cadeau." }, status: :unprocessable_entity
    end
  else
    if @gift.save
      render json: { success: true, notice: "Élément supprimé avec succès.", gift_destroyed: false }
    else
      render json: { success: false, notice: @gift.errors.full_messages }, status: :unprocessable_entity
    end
  end
end

  private

	def generate_list(gifts)
		max_attempts = 5
		attempts = 0
		list = []

		# begin
		# 	Timeout.timeout(30) do
				while list.length <= 1 && attempts < max_attempts
					list = @gift.gen_gifts(
						$client,
						@gift.budget,
						@gift.age,
						@gift.genre,
						@gift.occasion,
						@gift.interests,
						@gift.relationship
					).split(/\d+\.\s+/).map(&:strip).compact_blank
					attempts += 1
				end
			# end
		# rescue Timeout::Error
		# 	Rails.logger.error "La génération de cadeaux a pris trop de temps."
		# rescue StandardError => e
		# 	Rails.logger.error "Une erreur est survenue: #{e.message}"
		# end

		# if list.length > 1
			return list
		# end
	end

  def gift_params
    params.require(:gift).permit(:budget, :age, :genre, :occasion, [interests: []], :relationship, :generated_list,
                                 :comment, :user_id, :event_id)
  end

	def set_client
			$client = $client ? $client : OpenAI::Client.new
	end

	def check_user
		@user = current_user
		@gift = Gift.find(params[:id])
		if @user != @gift.user
			redirect_to root_path
		end
	end

	# def check_if_event
	# 	@gift = Gift.find(params[:id])
	# 	if @gift.event_id
	# 		redirect_to event_path(@gift.event_id)
	# 	end
	# end
end
