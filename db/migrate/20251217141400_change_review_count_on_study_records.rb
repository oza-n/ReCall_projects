class ChangeReviewCountOnStudyRecords < ActiveRecord::Migration[7.1]
  def change
    change_column_default :study_records, :review_count, :integer, default: 0, null: false
  end
end
