require 'rails_helper'

RSpec.describe 'StudyRecords', type: :system do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  # ==============================
  # 学習記録 詳細表示
  # ==============================
  describe '学習記録の詳細画面' do
    let!(:study_record) do
      create(
        :study_record,
        user: user,
        title: 'Railsの基礎',
        content: 'MVCについて学習した',
        category: 'rails',
        studied_at: Date.new(2025, 1, 1)
      )
    end

    it '学習記録の内容が表示される' do
      visit study_record_path(study_record)

      expect(page).to have_content('Railsの基礎')
      expect(page).to have_content('MVCについて学習した')
      expect(page).to have_content('カテゴリ')
      expect(page).to have_content('学習日')
      expect(page).to have_link('編集')
      expect(page).to have_button('削除')
      expect(page).to have_link('← 一覧に戻る')
    end
  end

  # ==============================
  # 復習可能な状態
  # ==============================
  describe '復習可能な学習記録' do
    let!(:study_record) do
      create( :study_record, user: user, next_review_at: Time.current - 1.day, review_count: 0 )
    end

    it '今すぐ復習するボタンが表示される' do
      visit study_record_path(study_record)

      expect(page).to have_button('今すぐ復習する')
    end

    it '復習ボタンを押すことができる' do
      visit study_record_path(study_record)

      click_button '今すぐ復習する'

      expect(page).to have_content('復習')
    end
  end

  # ==============================
  # 復習未到来の状態
  # ==============================
  describe '復習未到来の学習記録' do
    let!(:study_record) do
      create( :study_record, user: user, next_review_at: Time.current + 3.days, review_count: 0 )
    end

    it '下部の復習するボタンが表示される' do
      visit study_record_path(study_record)

      expect(page).to have_button('復習する')
      expect(page).not_to have_button('今すぐ復習する')
    end
  end

  # ==============================
  # 学習記録の編集
  # ==============================
  describe '学習記録の編集' do
    let!(:study_record) do
      create(:study_record, user: user, title: '編集前タイトル')
    end

    it '編集画面に遷移できる' do
      visit study_record_path(study_record)

      click_link '編集'

      expect(page).to have_field('study_record_title', with: '編集前タイトル')
    end
  end

  # ==============================
  # 学習記録の削除
  # ==============================
  describe '学習記録の削除' do
    let!(:study_record) do
      create(:study_record, user: user, title: '削除対象')
    end

    it '学習記録を削除できる' do
      visit study_record_path(study_record)

      accept_confirm do
        click_button '削除'
      end
      
      expect(page).to have_content('学習記録を削除しました')
      expect(page).not_to have_content('削除対象')
    end
  end
end