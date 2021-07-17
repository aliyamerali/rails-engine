class Api::V1::MerchantsController < ApplicationController
  def index
    page = params[:page].try(:to_i) || 1
    per_page = params[:per_page].try(:to_i) || 20
    merchants = Merchant.all.paginate(per_page, page)
    render json: MerchantsSerializer.format_merchants(merchants)
  end
end
