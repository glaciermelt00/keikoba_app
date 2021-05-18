class Post < ApplicationRecord
  belongs_to :user
  has_many_attached :images
  default_scope -> { order(created_at: :desc) }
  validates :user_id, presence: true
  validates :images, content_type: { in: %w[image/jpeg image/gif image/png], message: '：有効な画像フォーマットを使用してください' },
                     size: { less_than: 5.megabytes, message: '：5MB未満にしてください' }

  # 表示用のリサイズ済み画像を返す
  def display_image
    images.first.variant(resize_to_limit: [500, 500])
  end
end
