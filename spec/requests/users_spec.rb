require 'rails_helper'

RSpec.describe "Users", type: :request do
  let!(:admin) { create(:user, role: :admin) }
  let!(:user) { create(:user, user_name: "一般ユーザー", role: :employee) }

  before do
    sign_in admin
  end

  describe "GET /users" do
    it "ユーザー一覧が表示される" do
      get users_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("ユーザー一覧")
      expect(response.body).to include(admin.user_name)
      expect(response.body).to include(user.user_name)
    end
  end

  describe "GET /users/:id/edit" do
    it "編集フォームが表示される" do
      get edit_user_path(user)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /users/:id" do
    context "有効なパラメータの場合" do
      it "ユーザー情報が更新され、リダイレクトされる" do
        patch user_path(user), params: {
          user: { user_name: "新しい名前" }
        }
        expect(response).to redirect_to(users_path)
        follow_redirect!
        expect(response.body).to include("新しい名前")
      end
    end

    context "無効なパラメータの場合" do
      it "更新されずに再描画される" do
        patch user_path(user), params: {
          user: { employee_id: "" }
        }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /users/:id" do
    it "削除対象ユーザーだけを削除して一覧にリダイレクトされる" do
      deletable_user = create(:user, user_name: "削除対象ユーザー", email: "deletable@example.com")
      expect {
        delete user_path(deletable_user)
      }.to change(User, :count).by(-1)
      expect(response).to redirect_to(users_path)
      expect(User.find_by(email: "deletable@example.com")).to be_nil
    end
  end
end
