require 'rails_helper'

RSpec.describe "Users auto-fill by employee_id", type: :request do
  let!(:user) { create(:user, employee_id: "EMP123", user_name: "山田 太郎", department: :planning, role: :employee) }

  describe "GET /users/find_by_employee_id" do
    context "存在する社員IDを指定した場合" do
      it "ユーザー情報をJSONで返す" do
        get "/users/find_by_employee_id", params: { employee_id: "EMP123" }

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)

        expect(json["user_name"]).to eq("山田 太郎")
        expect(json["department"]).to eq("planning")
        expect(json["role"]).to eq("employee")
      end
    end

    context "存在しない社員IDを指定した場合" do
      it "404を返す" do
        get "/users/find_by_employee_id", params: { employee_id: "NOT_EXIST" }

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
