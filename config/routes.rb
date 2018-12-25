Twitarr::Application.routes.draw do
  root 'home#index'

  get 'time', to: 'home#time'

  post 'login', to: 'user#login'

  get 'alerts', to: 'alerts#index'
  get 'alerts/check', to: 'alerts#check'

  get 'announcements', to: 'announcements#index'

  get 'search/:text', to: 'search#search'
  get 'search_users/:text', to: 'search#search_users'
  get 'search_tweets/:text', to: 'search#search_tweets'
  get 'search_forums/:text', to: 'search#search_forums'
  get 'search_events/:text', to: 'search#search_events'

  get 'user/username'
  get 'user/forgot_password'
  post 'user/forgot_password', to: 'user#security_question'
  get 'user/security_answer'
  post 'user/security_answer', to: 'user#security_answer'
  get 'user/logout'
  get 'user/starred'
  get 'user/autocomplete'
  post 'user/save_profile'
  get 'user/profile/:username', to: 'user#show'
  get 'user/profile/:username/star', to: 'user#star'
  get 'user/profile/:username/vcf', to: 'user#vcard', format: false
  post 'user/profile/:username/personal_comment', to: 'user#personal_comment'

  get 'admin/users'
  get 'admin/users/:text', to: 'admin#user'
  post 'admin/activate'
  post 'admin/reset_password'
  post 'admin/update_user'
  post 'admin/new_announcement'
  get 'admin/announcements'
  post 'admin/upload_schedule'

  resources :forums, except: [:show, :destroy, :edit, :new] do
    collection do
      get ':page', to: 'forums#page'
      get 'thread/:id', to: 'forums#show'
      get 'thread/:id/:page', to: 'forums#show'
      post 'new_post'
      put 'thread/:forum_id/:forum_post_id', to: 'forums#update'
      delete 'thread/:forum_id/:forum_post_id', to: 'forums#delete_post'
    end
  end

  resources :seamail, except: [:destroy, :edit, :new] do
    collection do
      post 'new_message'
    end
  end
  put 'seamail/:id/recipients', to: 'seamail#recipients'

  get 'stream/star/:page', to: 'stream#star_filtered_page'
  get 'stream/:page', to: 'stream#page'
  post 'stream', to: 'stream#create'
  post 'tweet/edit/:id', to: 'stream#edit'
  get 'tweet/like/:id', to: 'stream#like'
  get 'tweet/unlike/:id', to: 'stream#unlike'
  get 'tweet/destroy/:id', to: 'stream#destroy'
  get 'tweet/:id', to: 'stream#get'

  post 'photo/upload'
  get 'photo/small_thumb/:id', to: 'photo#small_thumb'
  get 'photo/medium_thumb/:id', to: 'photo#medium_thumb'
  get 'photo/full/:id', to: 'photo#full'

  get 'location/autocomplete/:query', to: 'location#auto_complete'
  get 'location', to: 'location#index'
  post 'location', to: 'location#create'
  delete 'location/:name', to: 'location#delete'

  resources :event, except: [:index, :edit, :new] do
    collection do
      get 'mine/:day', to: 'event#mine'
      get 'all/:day', to: 'event#all'
      get 'csv'
    end
    member do
      post 'follow'
      post 'unfollow'
      get 'ical'
    end
  end

  namespace :api do
    namespace :v2 do
      resources :photo, only: [:index, :create, :destroy, :update, :show], :defaults => { :format => 'json' }
      resources :stream, only: [:index, :new, :create, :show, :destroy, :update]
      resources :event, only: [:index, :show]

      get 'event/:id/ical', to: 'event#ical'
      post 'event/:id/favorite', to: 'event#favorite'
      delete 'event/:id/favorite', to: 'event#destroy_favorite'
      get 'event/rc/events', to: 'event#rc_events'

      get 'forums', to: 'forums#index'
      put 'forums', to: 'forums#create'
      get 'forums/thread/:id', to: 'forums#show'
      post 'forums/thread/:id', to: 'forums#new_post'
      get 'forums/thread/:id/like/:post_id', to: 'forums#like'
      get 'forums/thread/:id/unlike/:post_id', to: 'forums#unlike'
      post 'forums/thread/:id/react/:post_id/:type', to: 'forums#react'
      delete 'forums/thread/:id/react/:post_id/:type', to: 'forums#unreact'
      get 'forums/thread/:id/react/:post_id', to: 'forums#show_reacts'
      get 'forums/rc/forums', to: 'forums#rc_forums'
      get 'forums/rc/thread/:id', to: 'forums#rc_forum'

      post 'stream/:id/like', to: 'stream#like'
      delete 'stream/:id/like', to: 'stream#unlike'
      post 'stream/:id/react/:type', to: 'stream#react'
      delete 'stream/:id/react/:type', to: 'stream#unreact'
      get 'stream/:id/react', to: 'stream#show_reacts'
      get 'stream/m/:query', to: 'stream#view_mention'
      get 'stream/h/:query', to: 'stream#view_hash_tag'
      get 'stream/:id/like', to: 'stream#show_likes'
      get 'stream/rc/posts', to: 'stream#rc_posts'

      post 'user/new', to: 'user#new'
      get 'user/new_seamail', to: 'user#new_seamail'
      delete 'user/mentions', to:'user#reset_mentions'
      get 'user/mentions', to:'user#mentions'
      get 'user/auth', to: 'user#auth'
      post 'user/auth', to: 'user#auth'
      get 'user/logout', to: 'user#logout'
      post 'user/logout', to: 'user#logout'
      get 'user/whoami', to: 'user#whoami'
      get 'user/profile', to: 'user#whoami'
      post 'user/profile', to: 'user#update_profile'
      get 'user/profile/:username', to: 'user#show'
      get 'user/profile/:username/star', to: 'user#star'
      get 'user/profile/:username/vcf', to: 'user#vcard', format: false
      get 'user/autocomplete/:username', to: 'user#autocomplete'
      get 'user/view/:username', to: 'user#show'
      get 'user/starred', to: 'user#starred'
      get 'user/photo/:username', to: 'user#get_photo'
      post 'user/photo', to: 'user#update_photo'
      delete 'user/photo', to: 'user#reset_photo'
      get 'user/rc/users', to: 'user#rc_users'
      post 'user/rc/update_profile', to: 'user#rc_update_profile'

      get 'hashtag/repopulate', to: 'hashtag#populate_hashtags'
      get 'hashtag/ac/:query', to: 'hashtag#auto_complete'

      get 'search', to: 'search#search'
      get 'alerts', to: 'alerts#index'
      get 'alerts/check', to: 'alerts#check'

      resources :seamail, except: [:destroy, :edit, :new], :defaults => { :format => 'json' }
      post 'seamail/:id/new_message', to: 'seamail#new_message'
      put 'seamail/:id/recipients', to: 'seamail#recipients'
    end
  end

end
