class RevenueSerializer
  def self.merchant_revenue(merchant, revenue)
    {
      data:
        { "id": merchant.id.to_s,
          "type": 'merchant_revenue',
          "attributes":
           { "revenue": revenue } }
    }
  end

  def self.merchants_revenue(merchants)
    {
      data: merchants.map do |merchant|
        { "id": merchant.id.to_s,
          "type": 'merchant_name_revenue',
          "attributes":
           { "name": merchant.name,
             "revenue": merchant.revenue } }
      end
    }
  end

  def self.items_revenue(items)
    { data: items.map do |item|
      { "id": item.id.to_s,
        "type": 'item_revenue',
        "attributes":
         { "name": item.name,
           "description": item.description,
           "unit_price": item.unit_price,
           "merchant_id": item.merchant_id,
           "revenue": item.revenue } }
    end }
  end

  def self.all_revenue_over_range(revenue)
    {
      data:
        { "id": nil,
          "type": 'revenue',
          "attributes":
           { "revenue": revenue } }
    }
  end

  # def self.potential_revenue(invoices)
  #   { data: invoices.map do |invoice|
  #     { "id": invoice.id.to_s,
  #       "type": 'unshipped_order',
  #       "attributes":
  #        { "potential_revenue": invoice.potential_revenue } }
  #   end }
  # end

  def self.weekly_revenue(weekly_data)
    { data: weekly_data.map do |week_data|
      { "id": nil,
        "type": 'weekly_revenue',
        "attributes":
         { "week": week_data.week.to_date,
           "revenue": week_data.revenue } }
    end }
  end
end
