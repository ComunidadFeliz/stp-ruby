# frozen_string_literal: true

Stp::Engine.routes.draw do
  post :abono, to: 'webhooks#abono'
  post :estado, to: 'webhooks#estado'
end
