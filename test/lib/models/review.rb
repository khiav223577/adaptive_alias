# frozen_string_literal: true
class Review < ActiveRecord::Base
  belongs_to :reviewable, polymorphic: true

  belongs_to :post, ->{ where("`reviews`.`reviewable_type` = 'Post'") }, foreign_key: :reviewable_id
  belongs_to :paper, ->{ where("`reviews`.`reviewable_type` = 'Paper'") }, foreign_key: :reviewable_id
  belongs_to :article, ->{ where("`reviews`.`reviewable_type` = 'Article'") }, foreign_key: :reviewable_id
end
