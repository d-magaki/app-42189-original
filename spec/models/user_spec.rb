require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'バリデーション' do
    let(:user) { build(:user) }

    it "有効なユーザーは保存できること" do
      user = build(:user)
      expect(user).to be_valid
    end

    it "社員IDがないと無効" do
      user = build(:user, employee_id: nil)
      user.validate
      expect(user.errors[:employee_id]).to include("社員IDを入力してください")
    end

    it "氏名がないと無効" do
      user = build(:user, user_name: nil)
      user.validate
      expect(user.errors[:user_name]).to include("氏名を入力してください")
    end

    it "部署がないと無効" do
      user = build(:user, department: nil)
      user.validate
      expect(user.errors[:department]).to include("部署を選択してください")
    end

    it "権限がないと無効" do
      user = build(:user, role: nil)
      user.validate
      expect(user.errors[:role]).to include("権限を選択してください")
    end

    it "社員IDが重複すると無効" do
      create(:user, employee_id: "EMP001")
      user = build(:user, employee_id: "EMP001")
      user.validate
      expect(user.errors[:employee_id]).to include("この社員IDはすでに使われています")
    end
  end
end
