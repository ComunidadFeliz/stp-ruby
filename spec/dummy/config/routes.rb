# frozen_string_literal: true

Rails.application.routes.draw do
  mount Stp::Engine => '/stp'
end
