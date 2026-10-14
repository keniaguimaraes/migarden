class AddTelegramToUsers < ActiveRecord::Migration[7.0]
  def change
    change_table :users, bulk: true do |t|
      t.string :telegram_chat_id
      t.remove :callmebot_phone, :callmebot_api_key, type: :string
    end
  end
end
