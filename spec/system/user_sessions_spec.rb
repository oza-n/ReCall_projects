require 'rails_helper'

RSpec.describe "UserSessions", type: :system do
  let(:user) { create(:user) }

  describe 'ログイン' do
    context '正しい認証情報でログインできる' do
      it 'ログインできる' do
        visit new_user_session_path

        fill_in 'メールアドレス', with: user.email
        fill_in 'パスワード', with: user.password
        
        click_button 'ログイン'

        expect(page).to have_content('ログインしました。')
        # 実際のリダイレクト先に合わせる
        expect(current_path).to eq(study_records_path)
      end
    end

    context '誤った認証情報ではログインできない' do
      it 'ログインフォームが再表示される' do
        visit new_user_session_path

        fill_in 'メールアドレス', with: user.email
        fill_in 'パスワード', with: 'wrong_password'
        
        click_button 'ログイン'

        # ログインフォームが再表示されることを確認
        expect(current_path).to eq(new_user_session_path)
        expect(page).to have_button('ログイン')
      end
    end
  end

  describe 'ログアウト' do
    before do
      sign_in user
      visit root_path
    end

    it 'ログアウトできる' do
      expect(page).to have_content("ようこそ、 #{user.name}さん")
      
      click_link 'ログアウト'
      
      expect(page).to have_content('ログアウトしました。')
      expect(current_path).to eq(root_path)
      expect(page).to have_link('ログイン', href: new_user_session_path)
    end
  end
end