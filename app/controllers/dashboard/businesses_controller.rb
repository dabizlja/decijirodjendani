class Dashboard::BusinessesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_business, only: [:edit, :update, :destroy, :remove_image]
  before_action :ensure_owner, only: [:edit, :update, :destroy, :remove_image]

  def new
    @business = current_user.businesses.build
    @categories = Category.order(:name)
    @cities = City.order(:name)
    @tags = Tag.ordered
    build_pricing_plan_slots
  end

  def create
    @business = current_user.businesses.build(business_params)

    if @business.save
      redirect_to dashboard_root_path, notice: '🎉 Biznis je uspešno kreiran!'
    else
      @categories = Category.order(:name)
      @cities = City.order(:name)
      @tags = Tag.ordered
      build_pricing_plan_slots
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @categories = Category.order(:name)
    @cities = City.order(:name)
    @tags = Tag.ordered
    build_pricing_plan_slots
  end

  def update
    # Handle images separately to append instead of replace
    new_images = params.dig(:business, :images)&.reject(&:blank?)
    update_params = business_params
    update_params.delete(:images) if new_images.present?

    if @business.update(update_params)
      # Attach new images to existing ones
      @business.images.attach(new_images) if new_images.present?
      redirect_to dashboard_root_path, notice: '✅ Biznis je uspešno ažuriran!'
    else
      @categories = Category.order(:name)
      @cities = City.order(:name)
      @tags = Tag.ordered
      build_pricing_plan_slots
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @business.destroy
    redirect_to dashboard_root_path, notice: '🗑️ Biznis je uspešno obrisan!'
  end

  def analytics
    @analytics_today = @business.analytics_summary(:today)
    @analytics_week = @business.analytics_summary(:week)
    @analytics_month = @business.analytics_summary(:month)

    # Recent views for trend analysis
    @recent_views = @business.business_views
                             .where(created_at: 30.days.ago..)
                             .group("DATE(created_at)")
                             .count
  end

  def remove_image
    image_id = params[:image_id]
    image = @business.images.find(image_id)

    if image
      image.purge
      redirect_to edit_dashboard_business_path(@business), notice: "Slika je uspešno obrisana."
    else
      redirect_to edit_dashboard_business_path(@business), alert: "Slika nije pronađena."
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to edit_dashboard_business_path(@business), alert: "Slika nije pronađena."
  end

  private

  def set_business
    @business = Business.find(params[:id])
  end

  def ensure_owner
    redirect_to dashboard_root_path, alert: '❌ Nemate dozvolu za ovu akciju.' unless @business.user == current_user
  end

  def business_params
    permitted = params.require(:business).permit(
      :name,
      :description,
      :address,
      :phone,
      :email,
      :website,
      :category_id,
      :city_id,
      images: [],
      tag_ids: [],
      pricing_plans_attributes: [
        :id,
        :name,
        :plan_type,
        :base_price,
        :currency,
        :duration_minutes,
        :capacity_kids,
        :capacity_adults,
        :description,
        :price_unit,
        :minimum_quantity,
        :maximum_quantity,
        :active,
        :_destroy,
        discounts_attributes: [
          :id,
          :name,
          :label,
          :percentage_off,
          :amount_off,
          :starts_at,
          :ends_at,
          :active,
          :_destroy
        ]
      ]
    )

    permitted[:tag_ids]&.reject!(&:blank?)

    if permitted[:images]
      cleaned_images = permitted[:images].reject(&:blank?)
      if cleaned_images.any?
        permitted[:images] = cleaned_images
      else
        permitted.delete(:images)
      end
    end

    permitted
  end

  def build_pricing_plan_slots
    @business.pricing_plans.build if @business.pricing_plans.empty?
    @business.pricing_plans.each do |plan|
      plan.discounts.build if plan.discounts.empty?
    end
  end
end
