require 'rails_helper'

RSpec.describe "Projects access control", type: :request do
  let!(:admin) { create(:user, role: :admin) }
  let!(:employee) { create(:user, role: :employee) }
  let!(:project) { create(:project, user: admin) }

  describe "GET /projects/:id" do
    context "管理者の場合" do
      before { sign_in admin }

      it "売上・コスト・利益が表示される" do
        get project_path(project)
        expect(response.body).to include("売上")
        expect(response.body).to include("コスト")
        expect(response.body).to include("利益")
      end
    end

    context "一般社員の場合" do
      before { sign_in employee }

      it "売上・コスト・利益が表示されない" do
        get project_path(project)
        expect(response.body).not_to include("売上")
        expect(response.body).not_to include("コスト")
        expect(response.body).not_to include("利益")
      end
    end
  end

  describe "GET /projects" do
    context "管理者の場合" do
      before { sign_in admin }

      it "新規登録・分析・インポートボタンが表示される" do
        get projects_path
        expect(response.body).to include("新規登録")
        expect(response.body).to include("リスト分析")
        expect(response.body).to include("Data Import")
      end
    end

    context "一般社員の場合" do
      before { sign_in employee }

      it "新規登録・分析・インポートボタンが表示されない" do
        get projects_path
        expect(response.body).not_to include("新規登録")
        expect(response.body).not_to include("リスト分析")
        expect(response.body).not_to include("Data Import")
      end
    end
  end
end
