# spec/system/study_records_spec.rb
require 'rails_helper'

RSpec.describe 'StudyRecords', type: :system do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  let(:valid_attributes) do
    {
      title: "テストタイトル",
      content: "テスト内容",
      category: "ruby",
      studied_at: Date.today
    }
  end

  let(:updated_attributes) do
    {
      title: "更新されたタイトル",
      content: "更新内容",
      category: "rails",
      studied_at: Date.today
    }
  end

  # ==============================
  # 学習記録一覧
  # ==============================
  describe '一覧ページ' do
    let!(:study_record) { create(:study_record, user: user, title: '一覧確認用') }

    it '表示される' do
      visit study_records_path
      expect(page).to have_content('一覧確認用')
      expect(page).to have_link('新規作成')
    end
  end

  # ==============================
  # 学習記録作成
  # ==============================
  describe '新規作成' do
    it '作成できる' do
      visit new_study_record_path

      fill_in 'study_record_title', with: valid_attributes[:title]
      fill_in 'study_record_content', with: valid_attributes[:content]
      select valid_attributes[:category].capitalize, from: 'study_record_category'
      fill_in 'study_record_studied_at', with: valid_attributes[:studied_at]

      click_button '作成'

      expect(page).to have_content('学習記録を作成しました')
      expect(page).to have_content(valid_attributes[:title])
    end
  end

  # ==============================
  # 詳細表示
  # ==============================
  describe '詳細画面' do
    let!(:study_record) do
      create(:study_record, user: user, title: 'Railsの基礎', content: 'MVCについて学習した', category: 'rails', studied_at: Date.new(2025,1,1))
    end

    it '内容が表示される' do
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
  # 編集
  # ==============================
  describe '編集' do
    let!(:study_record) { create(:study_record, user: user, title: '編集前タイトル') }

    it '更新できる' do
      visit study_record_path(study_record)
      click_link '編集'

      fill_in 'study_record_title', with: updated_attributes[:title]
      fill_in 'study_record_content', with: updated_attributes[:content]
      select updated_attributes[:category].capitalize, from: 'study_record_category'
      fill_in 'study_record_studied_at', with: updated_attributes[:studied_at]

      click_button '更新'

      expect(page).to have_content('学習記録を更新しました')
      expect(page).to have_content('更新されたタイトル')
    end
  end

  # ==============================
  # 削除
  # ==============================
  describe '削除' do
    let!(:study_record) { create(:study_record, user: user, title: '削除対象') }

    it '削除できる' do
      visit study_record_path(study_record)

      accept_confirm do
        click_button '削除'
      end

      expect(page).to have_content('学習記録を削除しました')
      expect(page).not_to have_content('削除対象')
    end
  end

  # ==============================
  # 復習ボタン表示
  # ==============================
  describe '復習機能' do
    context '復習可能な学習記録' do
      let!(:study_record) { create(:study_record, user: user, next_review_at: 1.day.ago, review_count: 0) }

      it '今すぐ復習ボタンが表示される' do
        visit study_record_path(study_record)
        expect(page).to have_button('今すぐ復習する')
      end
    end

    context '復習未到来の学習記録' do
      let!(:study_record) { create(:study_record, user: user, next_review_at: 3.days.from_now, review_count: 0) }

      it '下部の復習ボタンのみ表示される' do
        visit study_record_path(study_record)
        expect(page).to have_button('復習する')
        expect(page).not_to have_button('今すぐ復習する')
      end
    end
  end
end
