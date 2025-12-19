class StudyRecordsController < ApplicationController
  before_action :set_study_record, only: %i[show edit update destroy review]

  def index
    Rails.logger.debug "page: #{params[:page]}"
    @study_records = current_user.study_records
                                 .order(studied_at: :desc)
                                 .page(params[:page])
                                 .per(20)
  end

  # before_actionで設定済み
  def show; end

  def new
    @study_record = StudyRecord.new
  end

  def create
    @study_record = current_user.study_records.build(study_record_params)

    if @study_record.save
      redirect_to study_record_path(@study_record), notice: '学習記録を作成しました'
    else
      flash.now[:alert] = '学習記録の作成に失敗しました'
      render :new, status: :unprocessable_entity
    end
  end

  # before_actionで設定済み
  def edit; end

  def update
    if @study_record.update(study_record_params)
      redirect_to @study_record, notice: '学習記録を更新しました'
    else
      flash.now[:alert] = '学習記録の更新に失敗しました'
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @study_record.destroy
      redirect_to study_records_path, notice: '学習記録を削除しました'
    else
      redirect_to study_records_path, alert: '学習記録の削除に失敗しました'
    end
  end

  # === 復習ロジック実行アクション ===
  def review
    if @study_record.review!
      message = if @study_record.next_review_at
                  "復習しました。次回の復習日は#{@study_record.next_review_at.strftime('%Y年%m月%d日')}です。"
                else
                  '復習しました。全ての復習が完了しました！'
                end
      redirect_to study_records_path, notice: message
    else
      redirect_to study_records_path, alert: 'この記録はすでに復習完了しています'
    end
  end

  private

  def set_study_record
    @study_record = current_user.study_records.find(params[:id])
  end

  def study_record_params
    params.require(:study_record).permit(:title, :content, :category, :studied_at)
  end
end
