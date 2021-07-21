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

    if limit > 0
      merchants = Merchant
              .joins(invoices: [:transactions, :invoice_items])
              .select('merchants.*, SUM(invoice_items.unit_price * invoice_items.quantity) AS revenue')
              .where(transactions: { result: 'success' })
              .where(invoices: { status: 'shipped' })
              .group(:id)
              .order('revenue DESC')
              .limit(limit)
      render json: RevenueSerializer.merchants_revenue(merchants)
    else
      render json: { response: 'Bad Request' }, status: :bad_request
    end
  end
end
