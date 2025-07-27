class SheetsController < ApplicationController
  def index
    @sheets = Sheet.all.group_by(&:row)
    render :sheet # ビュー名を sheet.html.erb にしたい場合
  end
end
