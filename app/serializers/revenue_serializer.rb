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
end
