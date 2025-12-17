class StudyRecord < ApplicationRecord
  belongs_to :user
  has_many :review_logs, dependent: :destroy

  validates :content, presence: true
  validates :category, presence: true
  validates :studied_at, presence: true

  def mark_reviewed!
    self.review_count += 1
    self.last_reviewed_at = Time.current
    save!
  end
end
