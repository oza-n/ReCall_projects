require 'rails_helper'

RSpec.describe StudyRecord, type: :model do
  describe 'バリデーション' do
    it '有効なstudy_recordを作成できる' do
      study_record = build(:study_record)
      expect(study_record).to be_valid
    end

    it 'contentが空の場合は無効' do
      study_record = build(:study_record, content: nil)
      expect(study_record).not_to be_valid
    end
  end

  describe 'デフォルト値' do
    it 'review_countの初期値は0' do
      study_record = create(:study_record)
      expect(study_record.review_count).to eq 0
    end
  end
end
