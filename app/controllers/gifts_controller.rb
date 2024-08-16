class GiftsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client, only: [:create]

  def index
    @gifts = Gift.all
  end

  def show
    @user = current_user
    @gift = Gift.find(params[:id])
    @event = @gift.event_id ? Event.find(@gift.event_id) : Event.new
    @gifts_to_display = @gift.generated_list.take(5)
		console

    respond_to do |format|
      format.html
      format.json { render json: @gift }
    end
  end

  def new
    @event = params[:event_id] ? Event.find(params[:event_id]) : Event.new
    @gift = Gift.new
    @gift.event = @event
  end

  def create
    @gift = Gift.new(gift_params)
    @event = params[:event_id] ? Event.find(params[:event_id]) : Event.new
    @gift.event = @event
    @gift.user = current_user
    @gift.interests = @gift.interests.compact_blank
    @gift.generated_list = @gift.gen_gifts(
      $client,
      @gift.budget,
      @gift.age,
      @gift.genre,
      @gift.occasion,
      @gift.interests,
      @gift.relationship
    ).split(/\d+\.\s+/).map(&:strip).compact_blank
		respond_to do |format|
				if @gift.save
						format.json { render json: @gift,
																 status: :created,
																 location: @event.persisted? ? event_gift_path(@event, @gift) : gift_path(@gift) }
				else
						format.json { render json: @gift.errors, status: :unprocessable_entity }
				end
		end
  end

  def update
    @gift = Gift.find(params[:id])
		@gift.comment = true
    comment = params[:comment]
    @gift.update(generated_list: @gift.update_gifts($client, comment,
                                                    @gift.interests).split(/\d+\.\s+/).map(&:strip).compact_blank)
    if @gift.save
      redirect_to gift_path(@gift)
    else
      render :new
    end
  end

  def updatelist
    @gift = Gift.find(params[:id])
    @gift.generated_list = [params[:gift][:generated_list]].flatten
    if @gift.save
      respond_to do |format|
        format.json { render json: @gift }
      end
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def gift_params
    params.require(:gift).permit(:budget, :age, :genre, :occasion, [interests: []], :relationship, :generated_list,
                                 :comment, :user_id, :event_id)
  end

	def set_client
			$client = $client ? $client : OpenAI::Client.new
	end
end
