class MerchantsSerializer
  def self.format_merchants(merchants)
    {
      data: merchants.map do |merchant|
        { "id": merchant.id.to_s,
          "type": 'merchant',
          "attributes":
           { "name": merchant.name } }
      end
    }
  end

  def self.format_merchant(merchant)
    { data:
        { "id": merchant.id.to_s,
          "type": 'merchant',
          "attributes":
           { "name": merchant.name } } }
  end

  def self.empty_response
    { data:
        { "id": nil,
          "type": 'merchant',
          "attributes":
           { "name": nil } } }
  end
end
