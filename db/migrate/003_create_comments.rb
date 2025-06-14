# frozen_string_literal: true

class CreateComments < ActiveRecord::Migration[8.0]
  def change
    create_table :comments do |t|
      t.text :body
      t.references :post, foreign_key: true
      t.timestamps
    end
  end
end
