class Api::V1::MerchantsController < ApplicationController
  def index
    page = params[:page].try(:to_i) || 1
    per_page = params[:per_page].try(:to_i) || 20
    merchants = Merchant.all.paginate(per_page, page)
    render json: MerchantsSerializer.format_merchants(merchants)
  end

  def show
    if params[:item_id] && Item.exists?(params[:item_id])
      merchant = Item.find(params[:item_id]).merchant
      render json: MerchantsSerializer.format_merchant(merchant)
    elsif params[:id] && Merchant.exists?(params[:id])
      merchant = Merchant.find(params[:id])
      render json: MerchantsSerializer.format_merchant(merchant)
    else
      render json: { response: 'Not Found' }, status: :not_found
    end
  end

  def find
    if params[:name] && params[:name] != ''
      merchant = Merchant.search_by_name(params[:name]) if params[:name]
      if merchant
        render json: MerchantsSerializer.format_merchant(merchant)
      else
        render json: MerchantsSerializer.empty_response
      end
    else
      render json: { response: 'Bad Request' }, status: :bad_request
    end
  end
end
