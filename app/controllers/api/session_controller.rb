module Api
  class SessionController < ApplicationController
    before_action :token_match, only: [:destroy]

    # POST /api/session
    def create
      user = User.find_by(email: session_params[:email])

      if user&.authenticate(session_params[:password])
        user.regenerate_token if user.token.nil?

        render json: json_response(user), status: :created
      else
        render json: { errors: { credentials: ['are invalid'] } }, status: :bad_request
      end
    end

    # DELETE /api/session
    def destroy
      user = User.find_by(token: token)

      user&.regenerate_token

      head :no_content
    end

    private

    def session_params
      params.require(:session).permit(:email, :password)
    end

    def json_response(user)
      { session: { token: user.token, user: UserSerializer.render_as_hash(user) } }
    end
  end
end
