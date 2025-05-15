module ProjectsHelper
  def should_show_in_list?(project, user, filter)
    return true if user.管理者?
    filter ||= "in_progress"

    key = department_key(user.department)
    return false unless key

    start_date = project.send("#{key}_start_date")
    end_date   = project.send("#{key}_end_date")

    return false if end_date.present?

    filter == "unstarted" ? start_date.nil? : start_date.present?
  end

  def project_department(project)
    ids = [project.planning_user_id, project.design_user_id, project.development_user_id].compact
    User.where(id: ids).pluck(:department).first || "未設定"
  end

  def project_completed?(project, dept)
    key = department_key(dept)
    return false unless key

    project.send("#{key}_end_date").present?
  end

  private

  def department_key(department)
    case department
    when "企画部" then "planning"
    when "情報設計部" then "design"
    when "開発部" then "development"
    else nil
    end
  end
end
