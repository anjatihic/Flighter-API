module Api
  class BookingsController < ApplicationController
    # GET /api/bookings
    def index
      render json: BookingSerializer.render(Booking.all, root: :bookings)
    end

    # GET /api/bookings/:id
    def show
      booking = Booking.find_by(id: params[:id])

      if booking
        render json: BookingSerializer.render(booking, root: :booking)
      else
        render json: { errors: "Couldn't find the Booking" }, status: :bad_request
      end
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
      booking = Booking.find_by(id: params[:id])
      if booking
        booking.destroy
      else
        render json: { errors: "Couldn't find Booking" }, status: :bad_request
      end
    end

    # PATCH /api/bookings/:id
    def update
      booking = Booking.find_by(id: params[:id])

      return booking_update(booking) if booking

      render json: { errors: "Couldn't find the Booking" }, status: :bad_request
    end

    private

    def booking_params
      params.require(:booking).permit(:no_of_seats, :seat_price, :user_id, :flight_id)
    end

    def booking_update(booking)
      if booking.update(booking_params)
        render json: BookingSerializer.render(booking, root: :booking)
      else
        render json: { errors: booking.errors }, status: :bad_request
      end
    end
  end
end
