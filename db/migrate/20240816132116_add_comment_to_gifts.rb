class AddCommentToGifts < ActiveRecord::Migration[7.1]
  def change
    add_column :gifts, :comment, :boolean, default: false
  end
end
