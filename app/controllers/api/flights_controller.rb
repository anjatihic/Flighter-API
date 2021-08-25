module Api
  class FlightsController < ApplicationController
    before_action :token_match, only: [:create, :update, :destroy]

    # GET /api/flights ----> available to everyone
    def index
      render json: FlightSerializer.render(Flight.all, root: :flights)
    end

    # GET /api/flights/:id ------> available to everyone
    def show
      flight = Flight.find(params[:id])

      render json: FlightSerializer.render(flight, root: :flight)
    end

    # POST /api/flights
    def create
      raise ResourceForbiddenError unless current_user.admin?

      flight = Flight.new(flight_params)

      if flight.save
        render json: FlightSerializer.render(flight, root: :flight), status: :created
      else
        render json: { errors: flight.errors }, status: :bad_request
      end
    end

    # DELETE /api/flights/:id
    def destroy
      raise ResourceForbiddenError unless current_user.admin?

      flight = Flight.find(params[:id])

      flight.destroy
    end

    # PATCH /api/flights/:id
    def update
      raise ResourceForbiddenError unless current_user.admin?

      flight = Flight.find(params[:id])

      return flight_update(flight) if flight
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
