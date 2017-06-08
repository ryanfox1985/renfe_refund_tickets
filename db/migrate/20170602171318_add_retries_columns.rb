class AddRetriesColumns < ActiveRecord::Migration[5.1]
  def change
    add_column :travels, :tries, :integer, default: 0
    add_column :travels, :last_try_refund_at, :datetime, default: nil
    add_column :travels, :eligible, :boolean, default: false

    remove_column :travels, :refund_at
    remove_column :travels, :refund_ok
  end
end
