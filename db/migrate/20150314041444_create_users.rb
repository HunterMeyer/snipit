class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.text :first_name 
      t.text :last_name
      t.text :email
      t.text :password_hash
      t.text :password_salt
      t.boolean :email_verification, default: false
      t.text :verification_code
      t.text :api_authtoken
      t.datetime :authtoken_expiry
      t.timestamps
    end
  end
end
