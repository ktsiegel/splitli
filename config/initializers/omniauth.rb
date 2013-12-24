# From online venmo-omniauth github docs

Rails.application.config.middleware.use OmniAuth::Builder do
  	if Rails.env == 'production'
		provider :venmo, '1462', 'rNhHB9bqt6t3Ur5hYwZdWTwxxLLCeG5q', scope: 'access_profile,access_friends,access_feed,make_payments', client_id: '66XvrVxegFwXTEjp7mHkkEQSBLxjAc8J'
	else
		provider :venmo, '1460', 'CdxBunuRcsQc7phDScUUuPuMcVTSwUxC', scope: 'access_profile,access_friends,access_feed,make_payments', client_id: '66XvrVxegFwXTEjp7mHkkEQSBLxjAc8J'
	end
end

OmniAuth.config.on_failure = Proc.new { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}