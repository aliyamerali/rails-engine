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

  def most_revenue_items
    limit = item_limit(params[:quantity])

    if limit.positive?
      items = Item.most_revenue(limit)
      render json: RevenueSerializer.items_revenue(items)
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

  def invoices_unshipped_potential
    limit = params[:quantity].to_i

    if limit.positive?
      invoices = Invoice.unshipped_potential_revenue(limit)
      render json: UnshippedOrderSerializer.new(invoices)
    else
      render json: { error: 'Bad Request' }, status: :bad_request
    end
  end

  def weekly_revenue
    weekly_data = Invoice.joins(:transactions, :invoice_items)
      .select("DATE_TRUNC('week', invoices.created_at) as week, SUM(invoice_items.unit_price * invoice_items.quantity) as revenue")
      .where(transactions: { result: 'success' })
      .where(invoices: { status: 'shipped' })
      .group("DATE_TRUNC('week', invoices.created_at)")
      .order("DATE_TRUNC('week', invoices.created_at)")

    render json: RevenueSerializer.weekly_revenue(weekly_data)
  end

  private

  def valid_date?(date)
    !date.nil? && date != ''
  end

  def item_limit(passed_param)
    if passed_param.nil?
      10
    else
      passed_param.to_i
    end
  end
end
