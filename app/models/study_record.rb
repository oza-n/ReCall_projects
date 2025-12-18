class StudyRecord < ApplicationRecord
  belongs_to :user
  has_many :review_logs, dependent: :destroy

  validates :content, presence: true
  validates :category, presence: true
  validates :studied_at, presence: true
  validates :next_review_at, presence: true
  validates :review_count, numericality: { greater_than_or_equal_to: 0 }
  validates :last_reviewed_at, presence: true, if: -> { review_count.positive? }

# レコード作成時に初回の復習日を設定するコールバック


  after_create :set_initial_review_date
# after_update :update_next_review_date, if: :saved_change_to_review_count?

# 復習実行時に呼ばれ、復習回数と最終復習日時を更新するメソッド
  def mark_reviewed!
    self.review_count += 1
    self.last_reviewed_at = Time.current
    save!
  end

  private
  # 初回の復習日を設定するメソッド
  def set_initial_review_date
    update!(
      review_count: 0,
      next_review_at: studied_at + 1.day
    )
  end

  # レビューの回数に応じて復習する日付を計算するメソッド
  def calculate_next_review_date
    case review_count
    when 0
      studied_at + 1.day
    when 1
      studied_at + 3.days
    else
      studied_at + 7.days
    end
  end

end
