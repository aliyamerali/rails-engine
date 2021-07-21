class Api::V1::RevenueController < ApplicationController
  #TODO = REFACTOR revenue into model method and add test
  def merchant_total_revenue
    if Merchant.exists?(params[:id])
      merchant = Merchant.find(params[:id])
      revenue = merchant.revenue
      render json: RevenueSerializer.merchant_revenue(merchant, revenue)
    else
      render json: { response: 'Not Found' }, status: :not_found
    end
  end
end
