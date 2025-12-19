FactoryBot.define do
  factory :study_record do
    association :user
    content { 'Study_recordの内容' }
    category { 'default_category' }
    studied_at { Time.current.yesterday }
    review_count { 0 }

    trait :completed do
      review_count { StudyRecord::MAX_REVIEW_TIMES }
      last_reviewed_at { Time.current }
      next_review_at { nil }
    end

    trait :need_review do
      review_count { 1 }
      last_reviewed_at { Time.current.days_ago(5.days) }
      next_review_at { Time.current.ago(1.day) }
    end

    trait :scheduled do
      review_count { 1 }
      last_reviewed_at { Time.current.days_ago(1.days) }
      next_review_at { Time.current.tomorrow }
    end
  end
end
