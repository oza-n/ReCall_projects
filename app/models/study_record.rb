class StudyRecord < ApplicationRecord
  belongs_to :user
  has_many :review_logs, dependent: :destroy

  #=== 定数 レビューの上限 ===
  MAX_REVIEW_TIMES = 3

  validates :content, presence: true
  validates :category, presence: true
  validates :studied_at, presence: true
  validates :review_count, numericality: { greater_than_or_equal_to: 0 }
  validates :last_reviewed_at, presence: true, if: -> { review_count&.positive? }
  validates :next_review_at, presence: true, unless: :review_complete?

  before_validation :initialize_review_schedule, on: :create

  scope :need_review, -> { where('next_review_at <= ?', Time.current).where.not(next_review_at: nil) }
  scope :completed_reviews, -> { where(review_count: MAX_REVIEW_TIMES) }


  # === 公開API（外から呼んでいい操作） ===

  def review!
    return false if review_complete?

    transaction do
      increment_review_count
      record_last_reviewed_at
      schedule_next_review
      save!
    end
  end

  # === レビュー回数の上限 ===
  def review_complete?
    review_count >= MAX_REVIEW_TIMES
  end

  private

  # === 初期化 ===
  def initialize_review_schedule
    return unless new_record?

    self.review_count ||= 0
    self.next_review_at ||= initial_review_date
  end


  # === 復習時の内部処理 ===
  def increment_review_count
    self.review_count += 1
  end

  def record_last_reviewed_at
    self.last_reviewed_at = Time.current
  end

  def schedule_next_review
    self.next_review_at = review_complete? ? nil : next_review_date
  end

  # === 日付計算（完全に隠蔽） ===
  def initial_review_date
    studied_at + 1.day
  end

  def next_review_date
    case review_count
    when 1
      last_reviewed_at + 3.days
    when 2
      last_reviewed_at + 7.days
    end
  end
end
