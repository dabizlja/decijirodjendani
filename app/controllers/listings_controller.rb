class ListingsController < ApplicationController
  before_action :load_filters, only: [:index]
  before_action :set_business, only: [:show]

  def index
    @businesses = Business.includes(:category, :city, :tags, :user, pricing_plans: :discounts)
                          .active
                          .order(:name)

    # Apply filters
    @businesses = @businesses.where(city: params[:city_id]) if params[:city_id].present?
    @businesses = @businesses.where(category: params[:category_id]) if params[:category_id].present?

    # Price range filtering using cached min/max prices (includes discounts)
    price_min = params[:price_min].presence&.to_f
    price_max = params[:price_max].presence&.to_f
    if price_min || price_max
      @businesses = @businesses.where.not(min_price: nil, max_price: nil)
      if price_min
        @businesses = @businesses.where("businesses.max_price >= ?", price_min)
      end
      if price_max
        @businesses = @businesses.where("businesses.min_price <= ?", price_max)
      end
    end

    availability_time = parse_availability_time(params[:availability_at])

    if availability_time
      unavailable_business_ids = Booking.where("start_time <= ? AND end_time > ?", availability_time, availability_time)
                                        .select(:business_id)
      @businesses = @businesses.where.not(id: unavailable_business_ids)
    end

    # Tag filtering
    if params[:tag_ids].present?
      tag_ids = params[:tag_ids].reject(&:blank?)
      if tag_ids.any?
        @businesses = @businesses.joins(:tags).where(tags: { id: tag_ids }).distinct
      end
    end

    # Search by name or description
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @businesses = @businesses.where(
        "businesses.name ILIKE ? OR businesses.description ILIKE ?",
        search_term, search_term
      )
    end

    # Pagination with kaminari (12 per page for infinite scroll)
    @businesses = @businesses.page(params[:page]).per(12)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def show
    # Track the view
    BusinessView.track_view(@business, request)

    @reviews = @business.reviews.includes(:user).recent
    @user_review = user_signed_in? ? @business.reviews.find_by(user: current_user) : nil
    @new_review = Review.new
    @new_message = Message.new
  end


  private

  def load_filters
    @cities = City.joins(:businesses).where(businesses: { active: true }).distinct.order(:name)
    @categories = Category.joins(:businesses).where(businesses: { active: true }).distinct.order(:name)
    @tags = Tag.joins(:businesses).where(businesses: { active: true }).distinct.order(:name)
    @price_bounds = Business.price_bounds
    @selected_price_min = (params[:price_min].presence || @price_bounds[:min]).to_i
    @selected_price_max = (params[:price_max].presence || @price_bounds[:max]).to_i
    @selected_availability_at = params[:availability_at].presence
  end

  def set_business
    @business = Business.active.includes(:category, :city, :tags, :user, pricing_plans: :discounts).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to venues_path, alert: "Biznis nije pronađen."
  end

  def parse_availability_time(value)
    return nil if value.blank?
    Time.zone.parse(value)
  rescue ArgumentError, TypeError
    nil
  end
end
