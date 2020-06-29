class UsersController < ApplicationController
  before_action :authorize, except: [:sign_up, :sign_up_process, :sign_in, :sign_in_process]
  before_action :redirect_to_top_if_signed_in, only: [:sign_up, :sign_in]
  
    # トップページ
  def top
    if params[:word].present?
      @posts = Post.where("caption like ?", "%#{params[:word]}%").order("id desc")
    else
      @posts = Post.all.order("id desc").page(params[:page])
    end
    @recommends = User.where.not(id: current_user.id).where.not(id: current_user.follows.pluck(:follow_user_id)).limit(3)
  end
    
    # ユーザー登録ページ
  def sign_up
    @user = User.new
    render layout: "application_not_login"
  end
  
   # ユーザー登録処理
  def sign_up_process
    user = User.new(user_params)
    if user.save
      user_sign_in(user)
      redirect_to top_path and return
    else
      # 登録が失敗したらユーザー登録ページへ
      flash[:danger] = "ユーザー登録に失敗しました。"
      redirect_to("/sign_up")
    end
  end
  
    # サインインページ
  def sign_in
    @user = User.new
    render layout: "application_not_login"
  end
  
  # サインイン処理
  def sign_in_process
    # パスワードをmd5に変換
    password_md5 = User.generate_password(user_params[:password])
    # メールアドレスとパスワードをもとにデータベースからデータを取得
    user = User.find_by(email: user_params[:email], password: password_md5)
    if user
      # セッション処理
      user_sign_in(user)
      # トップ画面へ遷移する
      redirect_to top_path and return
    else
      # サインインが失敗した場合
      flash[:danger] = "サインインに失敗しました。"
      redirect_to("/sign_in")
    end
  end
  
  # サインアウト
  def sign_out
    # ユーザーセッションを破棄
    user_sign_out
    # サインインページへ遷移
    redirect_to sign_in_path and return
  end
  
    # プロフィールページ
  def show
    # ここに処理を実装
    @user = User.find(params[:id])
    @posts = Post.where(user_id: @user.id)
  end
  
    # プロフィール編集ページ
  def edit
    @user = User.find(current_user.id)
  end
   
  # プロフィール更新処理
  def update
    # ここに処理を実装
    upload_file = params[:user][:image]
    if upload_file.present?
  # あった場合はこの中の処理が実行される
      # 画像のファイル名取得
      upload_file_name = upload_file.original_filename
      output_dir = Rails.root.join('public', 'users')
      output_path = output_dir + upload_file_name
      
      File.open(output_path, 'w+b') do |f|
        f.write(upload_file.read)
      end
      current_user.update(user_params.merge({image: upload_file.original_filename}))
      # データベースに更新
    else
      current_user.update(user_params)
    end
      redirect_to profile_path(current_user) and return
  end
  
  #   # パラメータを取得
  # def user_params
  #   params.require(:user).permit(:name, :email, :password, :comment)
  # end
  
    # フォロー処理
  def follow
    # ここに処理を実装
    @user = User.find(params[:id])
    
    if Follow.exists?(user_id: current_user.id, follow_user_id: @user.id)
      # フォローを解除
      Follow.find_by(user_id: current_user.id, follow_user_id: @user.id).destroy
    else
      # フォローする
      Follow.create(user_id: current_user.id, follow_user_id: @user.id)
    end
    redirect_back(fallback_location: top_path, notice: "フォローを更新しました。")
  end
  
    # フォローリスト
  def follow_list
      # プロフィール情報の取得
      @user = User.find(params[:id])
      # ここに処理を実装
      @users = User.where(id: Follow.where(user_id: @user.id).pluck(:follow_user_id))
  end
  
  #フォロワーリスト
  def follower_list
    @user = User.find(params[:id])
    @users = User.where(id: Follow.where(follow_user_id: @user.id).pluck(:user_id))
  end
  
  
    # 認証チェック
  def authorize
    redirect_to sign_in_path unless user_signed_in?
  end
  
  
  
  #22-3　プライベート　　　###不明
  private
  def user_params
    params.require(:user).permit(:name, :email, :password, :comment)
  end
end
