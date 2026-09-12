# Additive route: no replacement of upstream routes, policy, schema or frontend assets.
Rails.application.routes.append do
  get '/api/v1/accounts/:account_id/conversations/:conversation_id/hermes_context',
      to: 'api/v1/accounts/conversations/hermes_context#show'
end
