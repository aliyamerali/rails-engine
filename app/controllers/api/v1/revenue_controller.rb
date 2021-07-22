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
    start_date = DateTime.parse(params[:start])
    end_date = DateTime.parse(params[:end]) + 1
    # binding.pry

    revenue = Merchant
            .joins(invoices: %i[transactions invoice_items])
            .where(transactions: { result: 'success' })
            .where(invoices: { status: 'shipped' })
            .where("invoices.created_at >= ? AND invoices.created_at <= ?", start_date, end_date)
            .sum('invoice_items.unit_price * invoice_items.quantity')

    render json: RevenueSerializer.all_revenue_over_range(revenue)
  end
end
