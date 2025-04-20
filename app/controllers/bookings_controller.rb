class BookingsController < ApplicationController
  before_action :set_user

  def index
    @bookings = @user.bookings.includes(:room).order(created_at: :desc)
  end
  
  def new
    @booking = Booking.new
    @rooms = Room.all
  end

  def create
    start_time = booking_params[:start_time]
    end_time = booking_params[:end_time]
    room_ids = params[:room_ids].reject(&:blank?).map(&:to_i)
  
    if room_ids.size > 3
      flash.now[:alert] = "You can book a maximum of 3 rooms at a time."
      @booking = Booking.new
      @rooms = Room.all
      return render :new
    end
  
    @bookings = room_ids.map do |room_id|
      @user.bookings.new(
        room_id: room_id,
        start_time: start_time,
        end_time: end_time,
        status: 'pending'
      )
    end
  
    @bookings.each(&:calculate_total_price)
  
    if @bookings.any? { |b| b.total_price.nil? || b.total_price <= 0 }
      flash.now[:alert] = "One or more bookings have an invalid price."
      @booking = Booking.new
      @rooms = Room.all
      return render :new
    end
  
    Booking.transaction do
      @bookings.each(&:save!)
    end
  
    redirect_to user_bookings_path(@user), notice: 'Rooms booked successfully!'
  rescue => e
    flash.now[:alert] = "Error: #{e.message}"
    @booking = Booking.new
    @rooms = Room.all
    render :new
  end  

  def show
    @booking = Booking.find(params[:id])
  end

  def cancel
    @booking = @user.bookings.find(params[:id])
    
    refund_amount = @booking.total_price
  
    if Time.current - @booking.created_at <= 24.hours
      @refund_amount = @booking.total_price * 0.95 
      flash[:notice] = "Booking cancelled. 5% cancellation fee applied. Refund: #{@refund_amount}"
    else
      flash[:notice] = "Booking cancelled. Full refund:  #{@refund_amount}"
    end
  
    @booking.update(status: 'cancelled', total_price: refund_amount)
    redirect_to user_bookings_path(@user)
  end

  private

  def booking_params
    params.require(:booking).permit(:start_time, :end_time)
  end

  def set_user
    @user = User.find(params[:user_id])
  end
end
