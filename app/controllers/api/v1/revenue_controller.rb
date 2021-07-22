class Api::V1::RevenueController < ApplicationController
  def merchant_total_revenue
    if Merchant.exists?(params[:id])
      merchant = Merchant.find(params[:id])
      revenue = merchant.revenue
      render json: RevenueSerializer.merchant_revenue(merchant, revenue)
    else
      render json: { response: 'Not Found' }, status: :not_found
    end
  end

  def most_revenue_merchants
    limit = params[:quantity].to_i

    if limit.positive?
      merchants = Merchant.most_revenue(limit)
      render json: RevenueSerializer.merchants_revenue(merchants)
    else
      render json: { error: 'Bad Request' }, status: :bad_request
    end
  end

  def all_revenue_in_date_range
    if valid_date?(params[:start]) && valid_date?(params[:end])
      revenue = Invoice.revenue_in_date_range(params[:start], params[:end])
      render json: RevenueSerializer.all_revenue_over_range(revenue)
    else
      render json: { error: 'Bad Request' }, status: :bad_request
    end
  end

  private

  def valid_date?(date)
    !date.nil? && date != ''
  end
end
