class CreateTravels < ActiveRecord::Migration[5.1]
  def change
    create_table :travels do |t|
      t.string :pnr, null: false
      t.string :ticket_number, null: false
      t.string :origin
      t.string :destination
      t.date :departure_date
      t.datetime :refund_at, default: nil

      t.timestamps
      t.index [:pnr, :ticket_number], unique: true
    end
  end
end
