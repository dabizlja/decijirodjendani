class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_business

  def create
    if @business.reviews.exists?(user: current_user)
      redirect_to venue_path(@business), alert: "Već ste ostavili recenziju za ovaj biznis."
      return
    end

    @review = @business.reviews.new(review_params.merge(user: current_user))

    if @review.save
      redirect_to venue_path(@business), notice: "Hvala! Vaša recenzija je sačuvana."
    else
      redirect_to venue_path(@business), alert: @review.errors.full_messages.to_sentence
    end
  end

  private

  def set_business
    @business = Business.active.find(params[:business_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to venues_path, alert: "Biznis nije pronađen."
  end

  def review_params
    params.require(:review).permit(:rating, :comment)
  end
end
