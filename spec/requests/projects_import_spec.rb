require 'rails_helper'

RSpec.describe "Projects Import", type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe "POST /projects/import" do
    context "正しいExcelファイルをアップロードした場合" do
      let(:file_path) { Rails.root.join("spec", "fixtures", "files", "test_projects.xlsm") }
      let(:uploaded_file) do
        Rack::Test::UploadedFile.new(file_path, "application/vnd.ms-excel.sheet.macroEnabled.12")
      end

      it "案件をインポートし、一覧にリダイレクトされる" do
        expect {
          post import_projects_path, params: { file: uploaded_file }
        }.to change(Project, :count).by_at_least(1)

        expect(response).to redirect_to(projects_path)
      end
    end

    context "ファイルが添付されていない場合" do
      it "エラーメッセージと共に一覧に戻る" do
        post import_projects_path
        expect(response).to redirect_to(projects_path)
        follow_redirect!
        expect(response.body).to include("ファイルを選択してください")
      end
    end
  end
end
