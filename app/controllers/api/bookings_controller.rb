module Api
  class BookingsController < ApplicationController
    # GET /api/bookings
    def index
      render json: BookingSerializer.render(Booking.all, root: :bookings)
    end

    # GET /api/bookings/:id
    def show
      booking = Booking.find(params[:id])

      render json: BookingSerializer.render(booking, root: :booking)
    end

    # POST /api/bookings
    def create
      booking = Booking.new(booking_params)

      if booking.save
        render json: BookingSerializer.render(booking, root: :booking), status: :created
      else
        render json: { errors: booking.errors }, status: :bad_request
      end
    end

    # DELETE /api/bookings/:id
    def destroy
      booking = Booking.find(params[:id])

      booking.destroy
    end

    # PATCH /api/bookings/:id
    def update
      booking = Booking.find(params[:id])

      if booking.update(booking_params)
        render json: BookingSerializer.render(booking, root: :booking)
      else
        render json: { errors: booking.errors }, status: :bad_request
      end
    end

    private

    def booking_params
      params.permit(:no_of_seats, :seat_price, :user_id, :flight_id)
    end
  end
end
