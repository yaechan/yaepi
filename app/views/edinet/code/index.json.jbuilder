json.array!(@codes) do |code|
  json.extract! code, :edinetCode, :listing, :consolidation, :capital, :settlementMonth, :settlementDay, :nameJa, :nameEn, :nameYomi, :address, :industry, :securityCode
  json.url edinet_code_url(code, format: :json)
end
