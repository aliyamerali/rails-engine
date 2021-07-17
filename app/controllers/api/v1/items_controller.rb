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
end
