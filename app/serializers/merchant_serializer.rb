class MerchantSerializer
  include FastJsonapi::ObjectSerializer
  attributes :name
  def self.empty_response
    { data:
        { "id": nil,
          "type": 'merchant',
          "attributes":
           { "name": nil } } }
  end
end
