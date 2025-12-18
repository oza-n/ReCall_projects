class CreateStudyRecords < ActiveRecord::Migration[7.1]
  def change
    create_table :study_records do |t|
      t.references :user, null: false, foreign_key: true
      t.date :studied_at
      t.text :content
      t.string :category
      t.date :next_review_at
      t.integer :review_count
      t.datetime :last_reviewed_at

      t.timestamps
    end
  end
end
