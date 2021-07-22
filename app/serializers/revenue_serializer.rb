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

  def self.all_revenue_over_range(revenue)
    {
      data:
        { "id": nil,
          "type": 'revenue',
          "attributes":
           { "revenue": revenue } }
    }
  end
end
