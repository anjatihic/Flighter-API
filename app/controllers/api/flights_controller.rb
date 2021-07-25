module Api
  class FlightsController < ApplicationController
    # GET /api/flights
    def index
      render json: FlightSerializer.render(Flight.all, root: :flights)
    end

    # GET /api/flights/:id
    def show
      flight = Flight.find(params[:id])

      render json: FlightSerializer.render(flight, root: :flight)
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
      flight = Flight.find(params[:id])

      flight.destroy
    end

    # PATCH /api/flights/:id
    def update
      flight = Flight.find(params[:id])

      if flight.update(flight_params)
        render json: FlightSerializer.render(flight, root: :flight)
      else
        render json: { errors: flight.errors }, status: :bad_request
      end
    end

    private

    def flight_params
      params.permit(:name, :no_of_seats, :base_price, :departs_at, :arrives_at, :company_id)
    end
  end
end
