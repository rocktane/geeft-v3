class EventsController < ApplicationController
  # before_action :set_cache_headers
  before_action :authenticate_user!, except: [:home]
	before_action :owner, only: %i[edit update destroy]
  before_action :set_event, only: %i[show edit update destroy]

  def home
    if user_signed_in?
      @user = User.find(current_user.id)
      # Récupérer tous les évènements de l'utilisateur
      @events = Event.where(user: current_user.id).order(:date)
    else
      @user = 'guest'
    end
  end

  def dashboard
    @events = Event.where(user: current_user).order(:date)
		if !@events.empty?
			@today = Date.today
			@range = (@today.year..@today.next_year(10).year).to_a
			@events_dates = @events.map { |event| event.date.strftime('%Y-%m-%d') }
			start_date = [@events.first.date.beginning_of_month, Date.today.beginning_of_month].min
			end_date = [@events.last.date.beginning_of_month, @today.next_year(10).beginning_of_month].max
			@all_months = (start_date..end_date).map(&:beginning_of_month).uniq
			@future_events = Event.where(user: current_user).where('date >= ?', @today).order(:date)
			@events_by_month = @all_months.map do |month|
				unless @events.select { |e| e.date.beginning_of_month == month }.nil?
					[month, @events.select { |e| e.date.beginning_of_month == month }]
				end
			end.to_h
		end
  end

  def show
    @gift = @event.gift.nil? ? Gift.new : @event.gift
		@gifts_to_display = @gift.generated_list.take(5) if @gift
		@event_url = request.original_url
		@domain = request.host_with_port
  end

  def new
    @gift = params[:gift_id] ? Gift.find(params[:gift_id]) : Gift.new
    @event = Event.new(gift: @gift)
  end

  def create
    @gift = params[:gift_id] ? Gift.find(params[:gift_id]) : Gift.new
    @event = Event.new(event_params)
    @event.user = current_user
    @event.gift = @gift if @gift.present?
    if @event.save
      duplicate(@event) if @event.recurrent && !@event.occurrence_from.present?
      redirect_to event_path(@event), notice: "L'évènement a été créé avec succès."
    else
      render :new
    end
  end

  def edit; end

  def update
    respond_to do |format|
      if @event.update(event_params)
        f_occ = Event.where(occurrence_from: @event.occurrence_from || @event.id).where('date > ?', @event.date)
        if @event.recurrent
          if f_occ.empty?
            duplicate(@event)
          else
            f_occ.each do |occ|
              occ.update(name: @event.name, date: occ.date.change(day: @event.date.day, month: @event.date.month))
            end
          end
        else
          f_occ.destroy_all
        end
        format.html { redirect_to event_path(@event), notice: "L'évènement a été mis à jour." }
        format.json { render json: { message: 'L\'évènement a été mis à jour.', event: @event }, status: :ok }
      else
        format.html do
          flash.now[:alert] = "L'URL n'est pas valide ou il y a d'autres erreurs dans le formulaire."
          render :edit
        end
        format.json { render json: { errors: @event.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  rescue StandardError => e
    Rails.logger.error "LOGGER : Error updating event: #{e.message}"
    respond_to do |format|
      format.html { render file: "#{Rails.root}/public/500.html", layout: false, status: :internal_server_error }
      format.json { render json: { error: e.message }, status: :internal_server_error }
    end
  end

	# def redirect
	# 	@gift = Gift.find(params[:id])
	# 	if @gift.event_id.present?
	# 		redirect_to event_path(@gift.event)
	# 	else
	# 		redirect_to new_gift_event_path(@gift)
	# 	end
	# end

  def destroy
    if @event.recurrent || Event.where(occurrence_from: @event.id).exists?
      # Si l'événement a des occurrences futures, les supprimer
      occ = Event.where(occurrence_from: @event.occurrence_from || @event.id).where('date >= ?', @event.date)
      occ.each(&:destroy)
    end
    @event.destroy
    redirect_to dashboard_path, notice: 'Event and its future occurrences were successfully destroyed.'
  end

  private

  def duplicate(event)
    @events = Event.where(user: current_user).order(:date)
    @today = Date.today
    years_to_cover = [@events.last.date.year - @today.year, 10].max
    (1..(years_to_cover + 1)).each do |i|
      new_event = event.dup
      new_event.gift_list = []
      new_event.url = ''
      new_event.occurrence_from = event.id
      new_event.date = event.date.next_year(i)
      new_event.save
    end
  end

  def link
    @event = Event.find(params[:event_id])
    @gift = Gift.find(params[:gift_id])
    @event.gift_list = @gift.generated_list
    if @event.save
      redirect_to event_path(@event)
    else
      render 'gifts/show'
    end
  end

  def event_params
    params.require(:event).permit(:name, :date, :recurrent, :description, :url,
			:user_id, :gift_id, :event_id, gift_attributes: [:generated_list], gift_list: [])
  end

  def set_event
    @event = Event.find(params[:id])
  end

	def owner
		@event = Event.find(params[:id])
		@user = User.find(@event.user_id)
		redirect_to root_path unless current_user == @user
	end

  # def set_cache_headers
  #   response.headers['Cache-Control'] = 'no-cache, no-store, must-revalidate'
  #   response.headers['Pragma'] = 'no-cache'
  #   response.headers['Expires'] = '0'
  # end
end
