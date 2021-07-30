module Api
  class SessionsController < ApplicationController
    # POST /api/sessions
    def create
      user = User.find_by(email: session_params[:email])

      if user.authenticate(session_params[:password])
        user.regenerate_token if user.token.nil?

        render json: { session: { token: user.token, user: UserSerializer.render_as_hash(user) } }
      else
        render json: { errors: { credentials: ['are invalid'] } }
      end
    end

    def destroy
      user = User.find(params[:id])
      user.regenerate_token

      head :no_content
    end

    private

    def session_params
      params.require(:session).permit(:email, :password)
    end
  end
end
