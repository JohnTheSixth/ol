Rails.application.routes.draw do

  resources :businesses do
    collection do
      post "import"
    end
  end

  root 'businesses#new'

end