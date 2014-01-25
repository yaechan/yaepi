# -*- coding: utf-8 -*-

require 'open-uri'
require 'net/http'
require 'csv'
require 'zip'
require 'fileutils'

module EdinetCode
  def validate_params(params)
    params.each do |key, value|
      params.delete(key.to_sym) if params[key.to_sym].blank?
    end
    return params
  end

  def parse_params(params)
    @codes = Edinet::Code.all
    @codes = @codes.where("edinetCode = ?", params[:edinetCode]) if params[:edinetCode]
    @codes = @codes.where("listing = ?", params[:listing]) if params[:listing] &&
                                                              params[:listing] != "null"
    @codes = @codes.where("listing is NULL") if params[:listing] &&
                                                params[:listing] == "null"
    @codes = @codes.where("consolidation = ?", params[:consolidation]) if params[:consolidation] &&
                                                                          params[:consolidation] != "null"
    @codes = @codes.where("consolidation is NULL") if params[:consolidation] &&
                                                      params[:consolidation] == "null"
    @codes = @codes.where("capital >= ?", params[:capitalAbove]) if params[:capitalAbove] &&
                                                                    params[:capitalAbove] != "null"
    @codes = @codes.where("capital is NULL") if params[:capitalAbove] &&
                                                params[:capitalAbove] == "null"
    @codes = @codes.where("capital <= ?", params[:capitalFollowing]) if params[:capitalFollowing] &&
                                                                        params[:capitalFollowing] != "null"
    @codes = @codes.where("capital is NULL") if params[:capitalFollowing] &&
                                                params[:capitalFollowing] == "null"
    @codes = @codes.where("settlementMonth = ?", params[:settlementMonth]) if params[:settlementMonth] &&
                                                                          params[:settlementMonth] != "null"
    @codes = @codes.where("settlementMonth is NULL") if params[:settlementMonth] &&
                                                      params[:settlementMonth] == "null"
    @codes = @codes.where("settlementDay = ?", params[:settlementDay]) if params[:settlementDay] &&
                                                                      params[:settlementDay] != "null"
    @codes = @codes.where("settlementDay is NULL") if params[:settlementDay] &&
                                                    params[:settlementDay] == "null"
    @codes = @codes.where("nameJa LIKE ?", "%#{params[:nameJa]}%") if params[:nameJa]
    @codes = @codes.where("nameEn LIKE ?", "%#{params[:nameEn]}%") if params[:nameEn]
    @codes = @codes.where("nameYomi LIKE ?", "%#{params[:nameYomi]}%") if params[:nameYomi]
    @codes = @codes.where("address LIKE ?", "%#{params[:address]}%") if params[:address]
    @codes = @codes.where("industry LIKE ?", "%#{params[:industry]}%") if params[:industry]
    @codes = @codes.where("securityCode = ?", params[:securityCode]) if params[:securityCode] &&
                                                                        params[:securityCode] != "null"
    @codes = @codes.where("securityCode is NULL") if params[:securityCode] &&
                                                     params[:securityCode] == "null"
    return @codes
  end

  def parse_listing(listing)
    if listing.blank?
      listing = nil
    else
      listing = listing.to_s == "上場" ? true : false
    end
  end

  def parse_consolidation(consolidation)
    if consolidation.blank?
      consolidation = nil
    else
      consolidation = consolidation.to_s == "有" ? true : false
    end
  end

  def parse_settlement_date(date)
    month = date[0, date.index("月").to_i]
    day = date[date.index("月").to_i + 1, date.index("日").to_i - date.index("月").to_i - 1]
    if day == "末"
      if Date.today > Date.new(Date.today.year, month.to_i, -1)
        day = Date.new(Date.today.year + 1, month.to_i, -1).day
      else
        day = Date.new(Date.today.year, month.to_i, -1).day
      end
    end
    return [month, day]
  end

  def data_update
    path_download_file = "https://disclosure.edinet-fsa.go.jp/E01EW/download?1388032171110&uji.verb=W1E62071EdinetCodeDownload&uji.bean=ee.bean.W1E62071.EEW1E62071Bean&TID=W1E62071&PID=W1E62071&lgKbn=2&dflg=0&iflg=0&dispKbn=1"
    file_path_zip = "#{Rails.root}/tmp/edinet/code/download_edinetcode.zip"
    dir_path_csv = "#{Rails.root}/tmp/edinet/code/"
    file_name_csv = nil

    https = Net::HTTP::new("disclosure.edinet-fsa.go.jp", 443)
    https.use_ssl = true
    https.verify_mode = OpenSSL::SSL::VERIFY_NONE
    https.verify_depth = 5

    req = Net::HTTP::Get.new(path_download_file, {
      "User-Agent" => ""
      })

    File.open(file_path_zip.to_s, "wb") do |zip|
      response = https.request(req)
      zip.print response.body
    end

    Zip::File.open(file_path_zip) do |zip|
      zip.each do |entry|
        file_name_csv = dir_path_csv + entry.to_s
        FileUtils.mkdir_p(File.dirname(file_name_csv))
        zip.extract(entry, file_name_csv) { true }
      end
    end

    hash_code = {}
    CSV.foreach(file_name_csv, row_sep: "\r\n", encoding: "SJIS:UTF-8") do |row|
      next unless row[0] =~ /\A\w\w\w\w\w\w\Z/
      hash_code[row[0].to_s] = {
        :listing => parse_listing(row[2]),
        :consolidation => parse_consolidation(row[3]),
        :capital => row[4].blank? ? nil : row[4],
        :settlementMonth => parse_settlement_date(row[5])[0],
        :settlementDay => parse_settlement_date(row[5])[1],
        :nameJa => row[6].blank? ? nil : row[6],
        :nameEn => row[7].blank? ? nil : row[7],
        :nameYomi => row[8].blank? ? nil : row[8],
        :address => row[9].blank? ? nil : row[9],
        :industry => row[10].blank? ? nil : row[10],
        :securityCode => row[11].blank? ? nil : row[11].to_s[0, 4]
      }
    end

    Edinet::Code.transaction do
      Edinet::Code.delete_all
      hash_code.each do |edinetCode, campany|
        Edinet::Code.create(
          :edinetCode => edinetCode,
          :listing => campany[:listing],
          :consolidation => campany[:consolidation],
          :capital => campany[:capital],
          :settlementMonth => campany[:settlementMonth],
          :settlementDay => campany[:settlementDay],
          :nameJa => campany[:nameJa],
          :nameEn => campany[:nameEn],
          :nameYomi => campany[:nameYomi],
          :address => campany[:address],
          :industry => campany[:industry],
          :securityCode => campany[:securityCode]
        )
      end
    end
  end
end