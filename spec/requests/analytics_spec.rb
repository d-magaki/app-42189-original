require 'rails_helper'

RSpec.describe "Analytics", type: :request do
  let!(:admin) { create(:user, role: :admin) }
  let!(:project1) do
    create(:project,
      request_type: "新規依頼",
      request_content: "WEBアプリ制作",
      order_date: Date.today - 7,
      due_date: Date.today + 7,
      revenue: 100_000,
      cost: 50_000,
      profit: 50_000,
      status: :未着手,
      planning_user: admin
    )
  end

  before { sign_in admin }

  describe "GET /analytics" do
    it "レスポンスが成功し、必要な分析情報が含まれる" do
      get analytics_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include("カスタムグラフ")
      expect(response.body).to include("依頼種別割合")
      expect(response.body).to include("案件ステータス一覧")
      expect(response.body).to include("1日あたりの平均処理必要数")
    end

    it "カスタムチャートのデータが埋め込まれている" do
      get analytics_path

      labels_json = Nokogiri::HTML(response.body).at_css("#custom-chart-labels").text
      values_json = Nokogiri::HTML(response.body).at_css("#custom-chart-values").text

      expect(JSON.parse(labels_json)).to be_an(Array)
      expect(JSON.parse(values_json)).to be_an(Array)
    end
  end
end