class CreateEdinetCodes < ActiveRecord::Migration
  def change
    create_table :edinet_codes do |t|
      t.string :edinetCode       #EdinetCode
      t.boolean :listing         #上場区分
      t.boolean :consolidation   #連結有無
      t.integer :capital         #資本金
      t.integer :settlementMonth #決算月
      t.integer :settlementDay   #決算日
      t.string :nameJa           #提出者名
      t.string :nameEn           #提出者英名
      t.string :nameYomi         #提出者名ヨミ
      t.string :address          #所在地
      t.string :industry         #提出者業種
      t.string :securityCode     #証券コード

      t.timestamps
    end
  end
end
