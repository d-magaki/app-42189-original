module ProjectsHelper
  def should_show_in_list?(project, user, filter)
    return true if user.admin?
    filter ||= "in_progress"

    key = department_key(user.department)
    return false unless key

    start_date = project.send("#{key}_start_date")
    end_date   = project.send("#{key}_end_date")

    case filter
    when "unstarted"
      start_date.nil? && end_date.nil?
    when "in_progress"
      start_date.present? && end_date.nil?
    when "all"
      true
    else
      false
    end
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
