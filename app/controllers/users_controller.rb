class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy,
                                        :following, :followers]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy
  
  # def index
  #   #条件分岐
  #   @users = if params[:search]
  #     #searchされた場合は、原文+.where('name LIKE ?', "%#{params[:search]}%")を実行
  #     User.where(activated: true).paginate(page: params[:page]).where('name LIKE ?', "%#{params[:search]}%")
  #   else
  #     #searchされていない場合は、原文そのまま
  #     User.where(activated: true).paginate(page: params[:page])
  #   end
  # end
  
  def index
    @users = User.where(activated: true).paginate(page: params[:page]).search(params[:search])
  end
  
  # def show
  #   @user = User.find(params[:id])
  #   @microposts = @user.microposts.paginate(page: params[:page])
  #   redirect_to root_url and return unless @user.activated?
  # end
  
  def show
    @user = User.find(params[:id])
    # 検索拡張機能として.search(params[:search])を追加    
    @microposts = @user.microposts.paginate(page: params[:page]).search(params[:search])
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
    else
      render 'new'
    end
  end
  
  def edit
  end
  
  def update
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end
  
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end
  
  def following
    @title = "Following"
    @user  = User.find(params[:id])
    @users = @user.following.paginate(page: params[:page])
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user  = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end
  
  private

    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)
    end
    
    # beforeアクション

    # ログイン済みユーザーかどうか確認
    # def logged_in_user
    #   unless logged_in?
    #     store_location
    #     flash[:danger] = "Please log in."
    #     redirect_to login_url
    #   end
    # end
    
    # 正しいユーザーかどうか確認
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end
    
    # 管理者かどうか確認
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end
