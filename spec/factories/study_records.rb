FactoryBot.define do
  factory :study_record do
    association :user
    studied_at { Date.current}
    content { "Study_recordの内容" }
    category { "default_category" }
    next_review_at { Date.current + 1.day }
    review_count { 0 }
    last_reviewed_at { nil }
  end
end
