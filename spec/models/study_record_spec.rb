require 'rails_helper'

RSpec.describe StudyRecord, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end

  #-- バリデーションテスト
  describe 'validations' do
    let(:user) { create(:user) }
    let(:record) { build(:study_record, user: user) }

    # --- 基本的なバリデーション ---
    it { is_expected.to validate_presence_of(:content) }
    it { is_expected.to validate_presence_of(:category) }
    it { is_expected.to validate_presence_of(:studied_at) }
    it { is_expected.to validate_numericality_of(:review_count).is_greater_than_or_equal_to(0) }

    #-- review_count が 1以上のときの条件分岐テスト ---
    context 'when review_count is positive' do
      # -- last_reviewed_at が指定されていない場合 ---
      it 'is invalid without last_reviewed_at' do
        record.review_count = 1
        record.last_reviewed_at = nil

        expect(record).not_to be_valid
        expect(record.errors[:last_reviewed_at]).to be_present
      end
    end

    #-- review_count が 0のときの条件分岐テスト ---
    context 'when review_count is zero' do
      # --last_reviewed_at がなくても有効な場合 ---
      it 'is valid even without last_reviewed_at' do
        record.review_count = 0
        record.last_reviewed_at = nil

        expect(record).to be_valid
      end
    end

    #-- review_complete? が falseのときの条件分岐の場合 ---
    context 'when review is not completed' do
      before { record.review_count = described_class::MAX_REVIEW_TIMES - 1 }

      #  -- next_review_at が指定されていない場合 ---
      it 'requires next_review_at' do
        record.next_review_at = nil
        expect(record).not_to be_valid
      end
    end

    #-- review_complete? が trueのときの条件分岐の場合 ---
    context 'when review is completed' do
      #  -- next_review_at がなくても有効な場合 ---
      it 'is valid without next_review_at' do
        record.review_count = described_class::MAX_REVIEW_TIMES
        record.last_reviewed_at = Time.current
        record.next_review_at = nil

        expect(record).to be_valid
      end
    end
  end

  # -- コールバックテスト ---
  describe 'callbacks' do
    let(:user) { create(:user) }
    let(:record) { build(:study_record, user: user, review_count: nil, next_review_at: nil) }

    #-- 作成時にreview_countが0になる初期化テスト ---
    it 'sets review_count to zero on create' do
      record.save!
      expect(record.review_count).to eq(0)
    end

    # -- 作成時にnext_review_atが翌日に設定される初期化テスト ---
    it 'sets next_review_at to the next day on create' do
      Timecop.freeze(Time.zone.local(2024, 12, 31, 10, 0, 0)) do
        record.studied_at = Time.current
        record.save!

        expect(record.next_review_at).to eq(Time.zone.today + 1.day)
      end
    end
  end

  # -- スコープテスト ---
  describe 'scopes' do
    let!(:user) { create(:user) }
    let!(:need_review_record) { create(:study_record, :need_review, user: user) }
    let!(:scheduled_record)   { create(:study_record, :scheduled, user: user) }
    let!(:completed_record)   { create(:study_record, :completed, user: user) }

    #-- .need_review スコープのテスト ---
    describe '.need_review' do
  let!(:need_review_record) { create(:study_record, :need_review) }
  let!(:scheduled_record)   { create(:study_record, :scheduled) }
  let!(:completed_record)   { create(:study_record, :completed) }

      # -- 過去のnext_review_atを持つレコードが含まれることの確認 ---
      it 'includes records with past next_review_at' do
        expect(described_class.need_review).to include(need_review_record)
      end

      # -- 未来のnext_review_atを持つレコードが含まれないことの確認 ---
      it 'does not include scheduled records' do
        expect(described_class.need_review).not_to include(scheduled_record)
      end

      # -- reviewが完了したレコードが含まれないことの確認 ---
      it 'does not include completed records' do
        expect(described_class.need_review).not_to include(completed_record)
      end
    end

    # -- .completed_reviews スコープのテスト ---
    describe '.completed_reviews' do
      # -- 完了したレコードが含まれることの確認 ---
      it 'includes completed records' do
        expect(described_class.completed_reviews).to include(completed_record)
      end

      # -- 未完了のレコードが含まれないことの確認 ---
      it 'does not include unfinished records' do
        expect(described_class.completed_reviews)
          .not_to include(need_review_record, scheduled_record)
      end
    end
  end

  # -- インスタンスメソッドのテスト ---
  describe 'instance methods' do
    let(:user) { create(:user) }
    let(:record) { create(:study_record, user: user, review_count: 0, studied_at: 1.day.ago) }

    # -- review_complete? メソッドのテスト ---
    describe '#review_complete?' do
      # -- review_count が最大値未満の場合 ---
      context 'when review_count is less than max' do
        before { record.review_count = described_class::MAX_REVIEW_TIMES - 1 }

        it { expect(record).not_to be_review_complete }
      end

      # -- review_count が最大値に達した場合 --
      context 'when review_count reaches max' do
        before { record.review_count = described_class::MAX_REVIEW_TIMES }

        it { expect(record).to be_review_complete }
      end
    end

    # -- review! メソッドのテスト ---
    describe '#review!' do
      #-- レビュー完了していない場合 ---
      context 'when review is not completed' do
        before { record.review_count = 0 }

        # -- 復習回数が1増えることの確認 ---
        it 'increments review_count' do
          expect { record.review! }.to change(record, :review_count).by(1)
        end

        # -- 復習完了後last_reviewed_at が現在時刻に更新されることの確認 ---
        it 'updates last_reviewed_at to current time' do
          Timecop.freeze do
            record.review!
            expect(record.last_reviewed_at).to be_within(1.second).of(Time.current)
          end
        end

        # -- メソッドが trueを返すことの確認 ---
        it 'returns true' do
          expect(record.review!).to be true
        end
      end

      #-- レビュー完了している場合 ---
      context 'when review_count reaches max' do
        before { record.review_count = described_class::MAX_REVIEW_TIMES }

        # -- 復習回数が増えないことの確認 ---
        it 'does not increment review_count' do
          expect { record.review! }.not_to change(record, :review_count)
        end

        # -- メソッドが falseを返すことの確認 ---
        it 'returns false' do
          expect(record.review!).to be false
        end
      end
    end
  end
end
