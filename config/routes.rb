Rails.application.routes.draw do
  resources :blogs
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end
