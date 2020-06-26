Rails.application.routes.draw do
    
    root 'users#top'
    get '/top', to:'users#top', as: :top
    
    get '/follow/(:id)', to:'users#follow', as: :follow
    
    get '/sign_up', to:'users#sign_up', as: :sign_up
    post '/sign_up', to:'users#sign_up_process'
    
    get '/sign_in', to:'users#sign_in', as: :sign_in
    post '/sign_in', to:'users#sign_in_process'
    
    get '/sign_out', to:'users#sign_out', as: :sign_out
    
    
    get '/profile/edit', to:'users#edit', as: :profile_edit
    post '/profile/edit', to:'users#update'
    
    get '/follower_list/(:id)', to:'users#follower_list', as: :follower_list
    
    get '/follow_list/(:id)', to:'users#follow_list', as: :follow_list
    get '/profile/(:id)', to:'users#show', as: :profile
    
    # IDは下の方に書く
    
    
    resources :posts do
        member do
            get 'like', to:'posts#like', as: :like
            post 'comment', to:'posts#comment', as: :comment
        end
    end
end
