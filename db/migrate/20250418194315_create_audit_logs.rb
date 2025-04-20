class CreateAuditLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :audit_logs do |t|
      t.string :action
      t.references :booking, null: false, foreign_key: true
      t.datetime :timestamp

      t.timestamps
    end
  end
end
