require 'rails_helper'

RSpec.describe StudyRecord, type: :model do
  # 関連付けのテスト
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end

  # バリデーションのテスト
  describe 'validations' do
    # Userファクトリを使用してUserを作成
    let(:user) { create(:user) }
    let(:record) { build(:study_record, user: user) }

    # 必須項目のテスト、必ず入力されていなければならない項目
    it { is_expected.to validate_presence_of(:content) }
    it { is_expected.to validate_presence_of(:category) }
    it { is_expected.to validate_presence_of(:studied_at) }

    # review_count のテスト、数値で0以上であること
    it { is_expected.to validate_numericality_of(:review_count).is_greater_than_or_equal_to(0) }

    # last_reviewed_at の条件付きバリデーション
    context 'review_countが正の値の場合' do
      before { record.review_count = 1 }
      it { is_expected.to validate_presence_of(:last_reviewed_at) }
    end

    context 'review_countが0の場合' do
      before { record.review_count = 0 }
      it { is_expected.not_to validate_presence_of(:last_reviewed_at) }
    end

    # next_review_at の条件付きバリデーション
    context '復習がまだ完了していない場合' do
      before { record.review_count = StudyRecord::MAX_REVIEW_TIMES - 1 }
      it { is_expected.to validate_presence_of(:next_review_at) }
    end

    context '復習が完了している場合' do
      before { record.review_count = StudyRecord::MAX_REVIEW_TIMES }
      it { is_expected.not_to validate_presence_of(:next_review_at) }
    end
  end

  # コールバックのテスト
  describe 'callbackのテスト' do
    let(:user) { create(:user) }
    let(:record) { build(:study_record, user: user, review_count: nil, next_review_at: nil) }

    it '新規作成時にreview_countを自動的に0にする場合' do
      record.save!
      expect(record.review_count).to eq(0)
    end

    it '新規作成時に復習日が翌日になるようにする場合' do
      record.studied_at = Time.zone.local(2025, 1, 1, 10, 0, 0)
      record.save!
      expected_date = Time.zone.local(2025, 1, 2, 10, 0, 0)
      expect(record.next_review_at).to be_within(1.second).of(expected_date)
    end
  end

  # スコープのテスト
  describe 'scopes' do
    let!(:user) { create(:user) }
    # ファクトリのtraitを使用してテストデータを準備
    let!(:need_review_record) { create(:study_record, :need_review, user: user) }
    let!(:scheduled_record) { create(:study_record, :scheduled, user: user) }
    let!(:completed_record) { create(:study_record, :completed, user: user) }

    # need_review スコープのテスト
    describe '復習が必要な学習記録を取得する場合' do
      it 'next_review_atが過去の記録を返す場合' do
        # need_review_record の next_review_at は過去
        expect(StudyRecord.need_review).to include(need_review_record)
      end

      it '次回復習日が未来の記録を返さない場合' do
        # scheduled_record の next_review_at は未来
        expect(StudyRecord.need_review).not_to include(scheduled_record)
      end

      it '既に復習が完了している記録を返さない場合' do
        # completed_record の next_review_at は nil
        expect(StudyRecord.need_review).not_to include(completed_record)
      end
    end

    # completed_reviews スコープのテスト
    describe 'すべての復習が完了した学習記録を取得する場合' do
      it '最大復習回数に達した記録を返す場合' do
        expect(StudyRecord.completed_reviews).to include(completed_record)
      end

      it '復習途中の記録は含めない' do
        expect(StudyRecord.completed_reviews).not_to include(need_review_record, scheduled_record)
      end
    end
  end

  # インスタンスメソッドのテスト
  describe 'インスタンスメソッドのテスト' do
    let(:user) { create(:user) }
    let(:record) { create(:study_record, user: user, review_count: 0, studied_at: Time.current.ago(1.day)) }

    # review_complete? のテスト
    describe 'この学習が復習完了かどうかを判断する' do
      context 'レビュー数が最大回数未満の場合' do
        before { record.review_count = StudyRecord::MAX_REVIEW_TIMES - 1 }
        it { expect(record.review_complete?).to be_falsey }
      end

      context 'レビュー数が最大回数に達した場合' do
        before { record.review_count = StudyRecord::MAX_REVIEW_TIMES }
        it { expect(record.review_complete?).to be_truthy }
      end
    end

    # review! のテスト
    describe '復習を一回実行する処理' do
      context '復習がまだ完了していない場合' do
        before { record.review_count = 0 }

        it '復習回数が１増える' do
          expect { record.review! }.to change { record.review_count }.by(1)
        end

        it '最後に復讐した日時が現在の時刻になる場合' do
          # Timecop.freeze を使用して現在時刻を固定
          Timecop.freeze do
            record.review!
            expect(record.last_reviewed_at).to be_within(1.second).of(Time.current)
          end
        end

        it '次回復習日が正しく設定される場合' do
          # review_count=0 -> 1 になるので、next_review_date は last_reviewed_at + 3.days
          record.review!
          expect(record.next_review_at).to be_within(1.second).of(record.last_reviewed_at + 3.days)
        end

        it '復習処理が完了したらtrueを返す場合' do
          expect(record.review!).to be_truthy
        end
      end

      context 'レビュー数が最大回数に達した場合' do
        before { record.review_count = StudyRecord::MAX_REVIEW_TIMES }

        it '復習回数が増加しない場合' do
          expect { record.review! }.not_to change { record.review_count }
        end

        it '既に復習が完了している場合はfalseを返す場合' do
          expect(record.review!).to be_falsey
        end
      end

      context 'レビュー数が最大回数に達した場合' do
        before { record.review_count = StudyRecord::MAX_REVIEW_TIMES - 1 }

        it '次回復習日がnilになる場合' do
          record.review!
          expect(record.next_review_at).to be_nil
        end
      end
    end

    # next_review_label のテスト
    describe '画面表示用の次回復習日ラベルを返す' do
      context '学習が完了した場合' do
        before { record.review_count = StudyRecord::MAX_REVIEW_TIMES }
        it { expect(record.next_review_label).to eq('復習完了') }
      end

      context 'レビュー数がnilの場合（コールバック後に発生しないはず）' do
        before { record.review_count = nil }
        it { expect(record.next_review_label).to eq('未復習') }
      end

      context '復習が予定されている場合' do
        let(:next_date) { Time.zone.local(2025, 12, 31) }
        before do
          record.review_count = 1
          record.next_review_at = next_date
        end
        it '次回復習日が正しく表示される場合 ' do
          expect(record.next_review_label).to eq('2025年12月31日')
        end
      end
    end

    # review_status のテスト
    describe '復習状態を返す' do
      context 'レビュー数が最大回数に達した場合' do
        before { record.review_count = StudyRecord::MAX_REVIEW_TIMES }
        it { expect(record.review_status).to eq(:complete) }
      end

      context 'next_review_at が過去の日付である場合' do
        before do
          record.review_count = 1
          # Timecop.freeze を使用して現在時刻を固定し、過去の next_review_at を設定
          Timecop.freeze(Time.current) do
            record.next_review_at = 1.day.ago
          end
        end
        it { expect(record.review_status).to eq(:overdue) }
      end

      context 'next_review_at が未来の日付である場合' do
        before do
          record.review_count = 1
          record.next_review_at = Time.current.tomorrow
        end
        it { expect(record.review_status).to eq(:scheduled) }
      end
    end
  end

  # next_review_date のプライベートメソッドのテスト (間接的にテスト)
  describe '復習予定日のロジック' do
    let(:user) { create(:user) }
    let(:record) { create(:study_record, user: user, last_reviewed_at: Time.current) }

    it 'レビュー回数 1 → 2 の場合、次のレビュー日時を計算します（3日後）' do
      record.review_count = 1
      # sendを使用してprivateメソッドを呼び出す
      record.send(:schedule_next_review)
      expect(record.next_review_at).to be_within(1.second).of(record.last_reviewed_at + 3.days)
    end

    it 'レビュー回数 2 → 3 の場合、次のレビュー日時を計算します（7日後）' do
      record.review_count = 2
      record.send(:schedule_next_review)
      expect(record.next_review_at).to be_within(1.second).of(record.last_reviewed_at + 7.days)
    end

    it 'レビュー回数が最大回数に達した場合、次回復習日をnilに設定します' do
      record.review_count = StudyRecord::MAX_REVIEW_TIMES
      record.send(:schedule_next_review)
      expect(record.next_review_at).to be_nil
    end
  end
end