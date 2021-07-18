class Api::V1::ItemsController < ApplicationController
  def index
    page = params[:page].try(:to_i) || 1
    per_page = params[:per_page].try(:to_i) || 20
    items = Item.all.paginate(per_page, page)
    render json: ItemsSerializer.format_items(items)
  end

  def show
    if Item.exists?(params[:id])
      item = Item.find(params[:id])
      render json: ItemsSerializer.format_item(item)
    else
      render json: { response: 'Not Found' }, status: :not_found
    end
  end

  def create
    item = Item.new(item_params)
    if item.save
      render json: ItemsSerializer.format_item(item), status: :created
    else
      render json: { response: 'Bad Request' }, status: :bad_request
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

  private

  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
  end
end
