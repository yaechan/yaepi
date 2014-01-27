  json.extract! @code, :edinet_code, :listing, :consolidation, :capital, :settlement_month, :settlement_day, :name_ja, :name_en, :name_yomi, :address, :industry, :security_code
  json.url edinet_code_url(@code, format: :json)

