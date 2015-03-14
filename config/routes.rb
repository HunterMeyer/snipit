SnipIt::Application.routes.draw do
  root 'home#index'

  get 'home/index'
  
  post 'api/signup'
  post 'api/signin'
  post 'api/reset_password'

  # post 'api/upload_snippet'
  # get 'api/get_snippet'
    
  get 'api/get_token'  
  get 'api/clear_token'
end
