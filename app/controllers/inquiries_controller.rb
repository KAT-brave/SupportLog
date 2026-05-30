class InquiriesController < ApplicationController
  before_action :set_inquiry, only: %i[edit update destroy]
  before_action :set_inquiry_with_associations, only: %i[show]
  before_action :ensure_editable_inquiry, only: %i[edit update destroy]

  def index
    @inquiries = Inquiry
      .active
      .includes(:assignee, :features)
      .order(created_at: :desc)
  end

  def show
    @status_histories = @inquiry
      .inquiry_status_histories
      .sort_by(&:created_at)
      .reverse
  end

  def new
    @inquiry = Inquiry.new(status: :unhandled, priority: :medium)
    @inquiry.assignee = Current.user
    load_master_data
  end

  def create
    @inquiry = Inquiry.new(inquiry_params)
    @inquiry.assignee = Current.user
    @inquiry.created_by = Current.user
    load_master_data

    feature_ids = params.dig(:inquiry, :feature_ids)&.reject(&:blank?) || []
    @inquiry.feature_ids = feature_ids

    if @inquiry.save
      redirect_to inquiries_path, notice: "問い合わせを登録しました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    load_master_data
  end

  def update
    load_master_data
    old_status = @inquiry.status

    @inquiry.assign_attributes(inquiry_params)
    @inquiry.updated_by = Current.user
    assign_features

    if old_status != @inquiry.status && params[:status_change_reason].blank?
      @inquiry.errors.add(:base, "ステータス変更理由を入力してください。")
      render :edit, status: :unprocessable_entity
      return
    end

    if @inquiry.save
      create_status_history_if_needed(old_status)
      redirect_to inquiries_path, notice: "問い合わせを更新しました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if params[:delete_reason].blank?
      redirect_to inquiries_path, alert: "削除理由を入力してください。"
      return
    end

    @inquiry.soft_delete!(
      reason: params[:delete_reason],
      deleted_by: Current.user
    )

    redirect_to inquiries_path, notice: "問い合わせを削除しました。"
  end

  private

  def set_inquiry
    @inquiry = Inquiry.active.find(params[:id])
  end

  def set_inquiry_with_associations
    @inquiry = Inquiry
      .active
      .includes(:assignee, :features, inquiry_status_histories: :changed_by)
      .find(params[:id])
  end

  def ensure_editable_inquiry
    return if Current.user.admin?
    return if @inquiry.assignee == Current.user

    redirect_to inquiries_path,
                alert: "この問い合わせを編集・削除する権限がありません。"
  end

  def inquiry_params
    params.require(:inquiry).permit(
      :title,
      :body,
      :response_content,
      :customer_name,
      :phone_number,
      :status,
      :priority,
      :due_date,
      feature_ids: []
    )
  end

  def load_master_data
    @features = Feature.order(:name)
  end

  def assign_features
    feature_ids = params.dig(:inquiry, :feature_ids)&.reject(&:blank?) || []
    @inquiry.feature_ids = feature_ids
  end

  def create_status_history_if_needed(old_status)
    return unless old_status != @inquiry.status
    return if params[:status_change_reason].blank?

    @inquiry.inquiry_status_histories.create!(
      from_status: old_status,
      to_status: @inquiry.status,
      reason: params[:status_change_reason],
      changed_by: Current.user
    )
  end
end
