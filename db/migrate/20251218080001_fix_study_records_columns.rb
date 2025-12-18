class FixStudyRecordsColumns < ActiveRecord::Migration[7.1]
  def change
    change_column_default :study_records, :review_count, from: nil, to: 0
    change_column_null :study_records, :review_count, false

    change_column_null :study_records, :studied_at, false
    change_column_null :study_records, :content, false
    change_column_null :study_records, :category, false
  end
end
