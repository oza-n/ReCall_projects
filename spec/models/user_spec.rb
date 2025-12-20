require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'バリデーションチェック' do
    it '有効なファクトリを持つこと' do
      user = build(:user)
      expect(user).to be_valid
    end

    it 'nameがない場合、無効であること' do
      user = build(:user, name: nil)
      expect(user).to be_invalid
      expect(user.errors[:name]).to be_present
    end

    it 'nameが空文字の場合、無効であること' do
      user = build(:user, name: '')
      expect(user).to be_invalid
      expect(user.errors[:name]).to be_present
    end

    it 'nameが20文字以内の場合、有効であること' do
      user = build(:user, name: 'a' * 20)
      expect(user).to be_valid
    end

    it 'nameが21文字以上の場合、無効であること' do
      user = build(:user, name: 'a' * 21)
      expect(user).to be_invalid
      expect(user.errors[:name]).to be_present
    end
  end

  describe 'アソシエーション' do
    it 'study_recordsと1対多の関係であること' do
      association = described_class.reflect_on_association(:study_records)
      expect(association.macro).to eq :has_many
    end

    it 'ユーザーが削除されたら、関連するstudy_recordsも削除されること' do
      user = create(:user)
      create(:study_record, user: user)
      expect { user.destroy }.to change(StudyRecord, :count).by(-1)
    end
  end
end
