class Edinet::CodeController < ApplicationController
  require 'module_edinet_code'
  include EdinetCode

  #/api/edinet/code(.html/.xml/.json)?query
  def index
    params = validate_params(search_params)
    @codes = parse_params(params)
    respond_to do |format|
      if search_params.length > 0
        format.html { render :action => "search.html.erb" }
      else
        format.html
      end
      format.xml { render :xml => @codes.to_xml({ :except => [:id, :created_at, :updated_at] }) }
      format.json { render :action => "index.json.jbuilder" }
    end
  end

  #/api/edinet/code/xxxxxx(.html/.xml/.json)
  def show
    @code = Edinet::Code.find(params[:id])
    respond_to do |format|
      format.html
      format.xml { render :xml => @code.to_xml({ :except => [:id, :created_at, :updated_at] }) }
      format.json
    end
  end

  private
    def search_params
      params.permit(:edinetCode, :listing, :consolidtion, :capitalAbove, :capitalFollowing, :settlementMonth, :settlementDay, :nameJa, :nameEn, :nameYomi, :address, :industry, :securityCode, :format)
    end
end
