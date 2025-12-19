class AddTitleToStudyRecords < ActiveRecord::Migration[7.1]
  def change
    add_column :study_records, :title, :string, null: false, default: ''
  end
end
