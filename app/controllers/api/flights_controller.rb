module Api
  class FlightsController < ApplicationController
    # GET /api/flights
    def index
      render json: FlightSerializer.render(Flight.all, root: :flights)
    end

    # GET /api/flights/:id
    def show
      flight = Flight.find_by(id: params[:id])

      if flight
        render json: FlightSerializer.render(flight, root: :flight)
      else
        render json: { errors: "Couldn't find the Flight" }, status: :not_found
      end
    end

    # POST /api/flights
    def create
      flight = Flight.new(flight_params)

      if flight.save
        render json: FlightSerializer.render(flight, root: :flight), status: :created
      else
        render json: { errors: flight.errors }, status: :bad_request
      end
    end

    # DELETE /api/flights/:id
    def destroy
      flight = Flight.find_by(id: params[:id])
      if flight
        flight.destroy
      else
        render json: { errors: "Couldn't find Flight" }, status: :not_found
      end
    end

    # PATCH /api/flights/:id
    def update
      flight = Flight.find_by(id: params[:id])

      return flight_update(flight) if flight

      render json: { errors: "Couldn't find the Flight" }, status: :not_found
    end

    private

    def flight_params
      params.require(:flight).permit(:name,
                                     :no_of_seats,
                                     :base_price,
                                     :departs_at,
                                     :arrives_at,
                                     :company_id)
    end

    def flight_update(flight)
      if flight.update(flight_params)
        render json: FlightSerializer.render(flight, root: :flight)
      else
        render json: { errors: flight.errors }, status: :bad_request
      end
    end
  end
end
