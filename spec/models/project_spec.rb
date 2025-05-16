require 'rails_helper'

RSpec.describe "Projects", type: :request do
  let!(:admin) { create(:user, role: :admin) }

  before do
    sign_in admin
  end

  describe "POST /projects" do
    context "有効なパラメータの場合" do
      it "新規作成されて詳細ページにリダイレクトする" do
        expect {
          post projects_path, params: {
            project: {
              customer_name: "新規顧客",
              sales_office: "名古屋支社",
              sales_representative: "佐藤一郎",
              request_type: "新規依頼",
              request_content: "WEBアプリ制作",
              order_date: Date.today,
              due_date: Date.today + 10,
              status: "未着手",
              revenue: 200_000,
              cost: 100_000,
              profit: 100_000,
              user_id: admin.id
            }
          }
        }.to change(Project, :count).by(1)

        follow_redirect!
        expect(response.body).to include("新規顧客")
      end

      it "添付ファイル付きで作成されること" do
        file = fixture_file_upload(Rails.root.join('spec/fixtures/test_file.txt'), 'text/plain')

        post projects_path, params: {
          project: {
            customer_name: "ファイル付き案件",
            sales_office: "大阪支社",
            sales_representative: "高橋太郎",
            request_type: "新規依頼",
            request_content: "WEBアプリ制作",
            order_date: Date.today,
            due_date: Date.today + 7,
            status: "未着手",
            revenue: 150_000,
            cost: 80_000,
            profit: 70_000,
            attachments: [file],
            user_id: admin.id
          }
        }

        project = Project.last
        expect(project.attachments.attached?).to be true
        expect(response).to redirect_to(project_path(project))
      end
    end

    context "無効なパラメータの場合" do
      it "作成されずに再描画されること" do
        expect {
          post projects_path, params: {
            project: {
              customer_name: "",
              sales_office: "",
              sales_representative: "",
              request_type: nil,
              request_content: nil,
              order_date: nil,
              due_date: nil,
              status: nil
            }
          }
        }.not_to change(Project, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /projects/:id" do
    let!(:deletable_project) {
      create(:project, customer_name: "削除対象プロジェクト", user: admin)
    }

    it "特定のプロジェクトを削除して一覧にリダイレクトされること" do
      expect {
        delete project_path(deletable_project)
      }.to change(Project, :count).by(-1)

      expect(response).to redirect_to(projects_path)
      expect(Project.find_by(customer_name: "削除対象プロジェクト")).to be_nil
    end
  end
end
