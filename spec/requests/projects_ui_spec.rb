require 'rails_helper'

RSpec.describe "Projects UI visibility by department", type: :request do
  shared_examples "部署別のUI表示確認" do |department, expected_texts, unexpected_texts|
    let!(:user) { create(:user, department: department.to_sym, role: :employee) }

    let!(:project) do
      case department.to_sym
      when :planning
        create(:project, planning_user: user, design_user: nil, development_user: nil)
      when :design
        create(:project, design_user: user, planning_user: nil, development_user: nil)
      when :development
        create(:project, development_user: user, planning_user: nil, design_user: nil)
      else
        create(:project)
      end
    end

    before { sign_in user }

    it "一覧に部署に応じた情報が表示される" do
      get projects_path
      expected_texts.each { |text| expect(response.body).to include(text) }
      unexpected_texts.each { |text| expect(response.body).not_to include(text) }
    end

    it "詳細に部署に応じた情報が表示される" do
      get project_path(project)
      expected_texts.each { |text| expect(response.body).to include(text) }
      unexpected_texts.each { |text| expect(response.body).not_to include(text) }
    end

    it "編集に部署に応じた情報が表示される" do
      get edit_project_path(project)
      expected_texts.each { |text| expect(response.body).to include(text) }
      unexpected_texts.each { |text| expect(response.body).not_to include(text) }
    end
  end

  context "企画部ユーザー" do
    it_behaves_like "部署別のUI表示確認",
      :planning,
      ["<th>企画担当者</th>", "<th>企画開始日</th>", "<th>企画完了日</th>"],
      ["<th>設計担当者</th>", "<th>設計開始日</th>", "<th>設計完了日</th>",
       "<th>開発担当者</th>", "<th>開発開始日</th>", "<th>開発完了日</th>"]
  end

  context "情報設計部ユーザー" do
    it_behaves_like "部署別のUI表示確認",
      :design,
      ["<th>設計担当者</th>", "<th>設計開始日</th>", "<th>設計完了日</th>"],
      ["<th>企画担当者</th>", "<th>企画開始日</th>", "<th>企画完了日</th>",
       "<th>開発担当者</th>", "<th>開発開始日</th>", "<th>開発完了日</th>"]
  end

  context "開発部ユーザー" do
    it_behaves_like "部署別のUI表示確認",
      :development,
      ["<th>開発担当者</th>", "<th>開発開始日</th>", "<th>開発完了日</th>"],
      ["<th>企画担当者</th>", "<th>企画開始日</th>", "<th>企画完了日</th>",
       "<th>設計担当者</th>", "<th>設計開始日</th>", "<th>設計完了日</th>"]
  end

  context "管理者ユーザー" do
    let!(:user) { create(:user, department: :planning, role: :admin) }
    let!(:project) { create(:project, planning_user: user, design_user: user, development_user: user) }

    before { sign_in user }

    it "全ての情報が表示される" do
      get projects_path
      expect(response.body).to include("企画担当者", "設計担当者", "開発担当者")
    end
  end
end
