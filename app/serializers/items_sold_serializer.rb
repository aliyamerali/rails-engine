class ItemsSoldSerializer
  include FastJsonapi::ObjectSerializer
  attributes :name, :count
end
