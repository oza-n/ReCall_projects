require 'rails_helper'

RSpec.describe 'UserRegistrations', type: :system do
  before do
    driven_by :rack_test
  end

  it '正常に登録できる' do
    visit new_user_registration_path
    fill_in 'user_name', with: 'テストユーザー'
    fill_in 'user_email', with: 'test@example.com'
    fill_in 'user_password', with: 'password123'
    fill_in 'user_password_confirmation', with: 'password123'
    click_button '登録' # 日本語ラベルに合わせる
    expect(page).to have_content('ようこそ')
  end

  it 'パスワードが一致しない場合は登録できない' do
    visit new_user_registration_path
    fill_in 'user_name', with: 'テストユーザー'
    fill_in 'user_email', with: 'test2@example.com'
    fill_in 'user_password', with: 'password123'
    fill_in 'user_password_confirmation', with: 'different_password'
    click_button '登録'
    # 修正: 期待値を実際の表示内容に合わせる
    expect(page).to have_content('パスワード（確認）とパスワードの入力が一致しません')
  end
end
