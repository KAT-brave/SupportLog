module InquiriesHelper
  def inquiry_status_label(status)
    {
      "unhandled" => "未対応",
      "in_progress" => "対応中",
      "completed" => "完了"
    }[status] || status
  end

  def inquiry_priority_label(priority)
    {
      "incident" => "障害",
      "high" => "高",
      "medium" => "中",
      "low" => "低"
    }[priority] || priority
  end
end