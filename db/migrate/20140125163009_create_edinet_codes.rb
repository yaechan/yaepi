class CreateEdinetCodes < ActiveRecord::Migration
  def change
    create_table :edinet_codes do |t|
      t.string :edinet_code       #EdinetCode
      t.boolean :listing         #上場区分
      t.boolean :consolidation   #連結有無
      t.integer :capital         #資本金
      t.integer :settlement_month #決算月
      t.integer :settlement_day   #決算日
      t.string :name_ja           #提出者名
      t.string :name_en           #提出者英名
      t.string :name_yomi         #提出者名ヨミ
      t.string :address          #所在地
      t.string :industry         #提出者業種
      t.string :security_code     #証券コード

      t.timestamps
    end
  end
end
