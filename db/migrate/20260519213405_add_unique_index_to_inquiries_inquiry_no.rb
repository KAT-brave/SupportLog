class AddUniqueIndexToInquiriesInquiryNo < ActiveRecord::Migration[8.0]
  def change
    add_index :inquiries, :inquiry_no, unique: true
  end
end
