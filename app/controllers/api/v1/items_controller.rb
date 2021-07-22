class Api::V1::ItemsController < ApplicationController
  def index
    if params[:merchant_id]
      merchants_items(params[:merchant_id])
    else
      page = params[:page].try(:to_i) || 1
      per_page = params[:per_page].try(:to_i) || 20
      @item = Item.all.paginate(per_page, page)
      render json: ItemSerializer.new(@item)
    end
  end

  def show
    if Item.exists?(params[:id])
      @item = Item.find(params[:id])
      render json: ItemSerializer.new(@item)
    else
      render json: { response: 'Not Found' }, status: :not_found
    end
  end

  def create
    @item = Item.new(item_params)
    if @item.save
      render json: ItemSerializer.new(@item), status: :created
    else
      render json: { response: 'Bad Request' }, status: :bad_request
    end
  end

  def update
    if Item.exists?(params[:id]) && valid_merchant?
      @item = Item.update(params[:id], item_params)
      render json: ItemSerializer.new(@item)
    else
      render json: { response: 'Not Found' }, status: :not_found
    end
  end

  def destroy
    if Item.exists?(params[:id])
      Item.delete(params[:id])
      render json: { response: 'No Content' }, status: :no_content
    else
      render json: { response: 'Not Found' }, status: :not_found
    end
  end

  def merchants_items(merchant_id)
    if Merchant.exists?(merchant_id)
      @item = Item.where(merchant_id: merchant_id)
      render json: ItemSerializer.new(@item)
    else
      render json: { response: 'Not Found' }, status: :not_found
    end
  end

  def find_all
    if valid_find_all?
      @item = Item.find_all(params[:name], params[:min_price], params[:max_price])
      render json: ItemSerializer.new(@item)
    else
      render json: { response: 'Bad Request' }, status: :bad_request
    end
  end

  private

  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
  end

  def valid_merchant?
    if item_params['merchant_id'] && !Merchant.exists?(item_params['merchant_id'].to_i)
      false
    else
      true
    end
  end

  def valid_find_all?
    name_only = (params[:name] && params[:name] != '') && !params[:min_price] && !params[:max_price]
    min_or_max_only = !params[:name] && (params[:min_price] || params[:max_price])
    min_and_max_only = !params[:name] && (params[:min_price] && params[:max_price])

    name_only || min_or_max_only || min_and_max_only
  end
end
