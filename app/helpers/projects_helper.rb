module ProjectsHelper
  # 上部リストの表示制御（自部署の全体を対象、自分が担当でなくてもOK）
  def should_show_in_list?(project, user, filter)
    return true if user.admin?
    should_show_in_list_for_user?(project, user, filter, require_own: false)
  end

  # 下部表の表示制御（各社員が自分で担当している案件のみカウント）
  def should_show_in_list_for_user?(project, user, filter, require_own: false)
    case user.department
    when "planning"
      return false if project.planning_end_date.present?
      return false if require_own && project.planning_user_id != user.id

      case filter
      when "unstarted"
        project.planning_start_date.nil? && project.planning_user_id.nil?
      when "in_progress"
        project.planning_start_date.present? && project.planning_end_date.nil? && project.planning_user_id.present?
      when "all"
        (project.planning_start_date.nil? && project.planning_user_id.nil?) ||
        (project.planning_start_date.present? && project.planning_end_date.nil? && project.planning_user_id.present?)
      else
        false
      end

    when "design"
      return false if project.planning_end_date.nil? || project.design_end_date.present?
      return false if require_own && project.design_user_id != user.id

      case filter
      when "unstarted"
        project.design_start_date.nil? && project.design_user_id.nil?
      when "in_progress"
        project.design_start_date.present? && project.design_end_date.nil? && project.design_user_id.present?
      when "all"
        (project.design_start_date.nil? && project.design_user_id.nil?) ||
        (project.design_start_date.present? && project.design_end_date.nil? && project.design_user_id.present?)
      else
        false
      end

    when "development"
      return false if project.design_end_date.nil? || project.development_end_date.present?
      return false if require_own && project.development_user_id != user.id

      case filter
      when "unstarted"
        project.development_start_date.nil? && project.development_user_id.nil?
      when "in_progress"
        project.development_start_date.present? && project.development_end_date.nil? && project.development_user_id.present?
      when "all"
        (project.development_start_date.nil? && project.development_user_id.nil?) ||
        (project.development_start_date.present? && project.development_end_date.nil? && project.development_user_id.present?)
      else
        false
      end

    else
      false
    end
  end

  # データベース部門名に対応
  def department_key(department)
    case department
    when "planning" then "planning"
    when "design" then "design"
    when "development" then "development"
    else nil
    end
  end
end
