class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  layout :layout_by_resource

  #    学習一覧ページ後に戻るように変更 pathを学習一覧ページにするようにする
  #   def after_sign_in_path_for(resource)
  #     pages_home_path
  #   end

  def after_sign_out_path_for(_resource_or_scope)
    pages_home_path
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end

  private

  def layout_by_resource
    devise_controller? ? 'devise' : 'application'
  end
end
