FactoryBot.define do
  factory :study_record do
    association :user
    sequence(:title) { |n| "学習記録_#{n}" }
    content { 'Study_recordの内容' }
    category { :rails }
    studied_at { Date.current }
    next_review_at { 1.day.from_now }
    review_count { 0 }
    last_reviewed_at { nil }

    trait :completed do
      review_count { StudyRecord::MAX_REVIEW_TIMES }
      last_reviewed_at { Time.current }
      next_review_at { 1.day.ago }
    end

    trait :need_review do
      review_count { 1 }
      last_reviewed_at { Time.current }
      next_review_at { 1.day.ago }
    end

    trait :scheduled do
      next_review_at { 1.day.from_now }
      review_count { 0 }
    end
  end
end
