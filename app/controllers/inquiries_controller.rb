class InquiriesController < ApplicationController
  before_action :set_inquiry, only: %i[show edit update soft_delete]

  def index
    @inquiries = Inquiry.active.order(created_at: :desc)
  end

  def show
  end

  def new
    @inquiry = Inquiry.new(status: :unhandled, priority: :medium)
    @inquiry.assignee = Current.user
    load_master_data
  end

def create
  @inquiry = Inquiry.new(inquiry_params)
  @inquiry.assignee = Current.user
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

    if old_status != inquiry_params[:status] && params[:status_change_reason].blank?
      @inquiry.assign_attributes(inquiry_params)
      @inquiry.errors.add(:base, "ステータス変更理由を入力してください。")
      render :edit, status: :unprocessable_entity
      return
    end

    if @inquiry.update(inquiry_params)
      assign_features
      create_status_history_if_needed(old_status)
      redirect_to inquiries_path, notice: "問い合わせを更新しました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def soft_delete
    if params[:delete_reason].blank?
      redirect_to inquiries_path, alert: "削除理由を入力してください。"
      return
    end

    @inquiry.soft_delete!(reason: params[:delete_reason])
    redirect_to inquiries_path, notice: "問い合わせを削除しました。"
  end

  private

  def set_inquiry
    @inquiry = Inquiry.find(params[:id])
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
    feature_ids = params[:inquiry][:feature_ids]&.reject(&:blank?) || []
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