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
          "type": 'merchant',
          "attributes":
           { "name": merchant.name,
             "revenue": merchant.revenue} }
      end
    }
  end
end
