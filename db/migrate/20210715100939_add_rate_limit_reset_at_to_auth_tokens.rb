class AddRateLimitResetAtToAuthTokens < ActiveRecord::Migration[5.2]
  def change
    add_column :auth_tokens, :rate_limit_reset_at, :datetime
  end
end
