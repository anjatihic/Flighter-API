module Api
  class BookingsController < ApplicationController
    before_action :token_match

    # GET /api/bookings
    def index
      if current_user.admin?
        render json: BookingSerializer.render(Booking.all, root: :bookings)
      else
        render json: BookingSerializer.render(current_user.bookings, root: :bookings)
      end
    end

    # GET /api/bookings/:id
    def show
      booking = Booking.find(params[:id])

      if current_user.admin? || current_user.id == booking.user_id
        render json: BookingSerializer.render(booking, root: :booking)
      else
        render json: { errors: { resource: ['forbidden'] } }, status: :forbidden
      end
    end

    # POST /api/bookings
    def create
      booking = Booking.new(booking_params)
      booking.user_id = current_user.id

      if booking.save
        render json: BookingSerializer.render(booking, root: :booking), status: :created
      else
        render json: { errors: booking.errors }, status: :bad_request
      end
    end

    # DELETE /api/bookings/:id
    def destroy
      booking = Booking.find(params[:id])
      if current_user.admin? || booking.user_id == current_user.id
        booking.destroy
      else
        render json: { errors: { resource: ['forbidden'] } }, status: :forbidden
      end
    end

    # PATCH /api/bookings/:id
    def update
      booking = Booking.find(params[:id])

      return booking_update(booking, admin_booking_params) if current_user.admin?

      return booking_update(booking, booking_params) if current_user.id == booking.user_id

      render json: { errors: { resource: ['forbidden'] } }, status: :forbidden
    end

    private

    def booking_params
      params.require(:booking).permit(:no_of_seats, :seat_price, :flight_id)
    end

    def admin_booking_params
      params.require(:booking).permit(:no_of_seats, :seat_price, :user_id, :flight_id)
    end

    def booking_update(booking, params)
      if booking.update(params)
        render json: BookingSerializer.render(booking, root: :booking)
      else
        render json: { errors: booking.errors }, status: :bad_request
      end
    end
  end
end
