module ProjectsHelper
  def should_show_in_list?(project, user, filter)
    return true if user.admin?
    filter ||= "in_progress"

    case user.department
    when "planning"
      return false if project.planning_end_date.present? # ✅ 完了案件除外
      case filter
      when "unstarted"
        (
          project.planning_user_id.nil? &&
          project.planning_start_date.nil? &&
          project.planning_end_date.nil?
        ) || (
          project.planning_user_id == user.id &&
          project.planning_start_date.nil? &&
          project.planning_end_date.nil?
        )
      when "in_progress"
        project.planning_user_id == user.id &&
          project.planning_start_date.present? &&
          project.planning_end_date.nil?
      when "all"
        (
          project.planning_user_id.nil? &&
          project.planning_start_date.nil? &&
          project.planning_end_date.nil?
        ) || (
          project.planning_user_id == user.id &&
          (
            project.planning_start_date.nil? ||
            (project.planning_start_date.present? && project.planning_end_date.nil?)
          )
        )
      else
        false
      end

    when "design"
      return false if project.planning_end_date.nil? || project.design_end_date.present? # ✅ 前工程未完了または自工程完了は除外
      case filter
      when "unstarted"
        (project.design_user_id.nil? || project.design_user_id == user.id) &&
          project.design_start_date.nil? &&
          project.design_end_date.nil?
      when "in_progress"
        project.design_user_id == user.id &&
          project.design_start_date.present? &&
          project.design_end_date.nil?
      when "all"
        (
          project.design_user_id.nil? &&
          project.design_start_date.nil? &&
          project.design_end_date.nil?
        ) || (
          project.design_user_id == user.id &&
          (
            project.design_start_date.nil? ||
            (project.design_start_date.present? && project.design_end_date.nil?)
          )
        )
      else
        false
      end

    when "development"
      return false if project.design_end_date.nil? || project.development_end_date.present? # ✅ 前工程未完了または自工程完了は除外
      case filter
      when "unstarted"
        (project.development_user_id.nil? || project.development_user_id == user.id) &&
          project.development_start_date.nil? &&
          project.development_end_date.nil?
      when "in_progress"
        project.development_user_id == user.id &&
          project.development_start_date.present? &&
          project.development_end_date.nil?
      when "all"
        (
          project.development_user_id.nil? &&
          project.development_start_date.nil? &&
          project.development_end_date.nil?
        ) || (
          project.development_user_id == user.id &&
          (
            project.development_start_date.nil? ||
            (project.development_start_date.present? && project.development_end_date.nil?)
          )
        )
      else
        false
      end

    else
      false
    end
  end

  def department_key(department)
    case department
    when "planning" then "planning"
    when "design" then "design"
    when "development" then "development"
    else nil
    end
  end
end
