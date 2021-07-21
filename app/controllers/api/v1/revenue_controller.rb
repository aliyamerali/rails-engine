class Api::V1::RevenueController < ApplicationController
  def merchant_total_revenue
    if Merchant.exists?(params[:id])
      merchant = Merchant.find(params[:id])
      revenue = merchant.invoices
              .joins(:transactions, :invoice_items)
              .where(transactions: {result: "success"})
              .where(invoices: {status: "shipped"})
              .sum('invoice_items.unit_price * invoice_items.quantity')
      render json: RevenueSerializer.merchant_revenue(merchant, revenue)
    else
      render json: { response: 'Not Found' }, status: :not_found
    end
  end
end
