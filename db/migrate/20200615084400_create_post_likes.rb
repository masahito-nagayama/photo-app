class CreatePostLikes < ActiveRecord::Migration[5.0]
  def change
    create_table :post_likes do |t|
      t.references :user, foreign_key: true
      t.references :post, foreign_key: true

      t.timestamps
    end
  end
end
