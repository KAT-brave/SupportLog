class AddResponseContentToInquiries < ActiveRecord::Migration[8.1]
  def change
    add_column :inquiries, :response_content, :text
  end
end
