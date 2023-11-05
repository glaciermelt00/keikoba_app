class Post < ApplicationRecord
  belongs_to :user
  has_many :favorites, dependent: :destroy
  has_many :bookmarks, dependent: :destroy
  has_many_attached :images
  default_scope -> { order(created_at: :desc) }
  validates :name, presence: true
  validates :user_id, presence: true
  validates :images, content_type: { in: %w[image/jpeg image/gif image/png], message: '：有効な画像フォーマットを使用してください' },
                     size: { less_than: 5.megabytes, message: '：5MB未満にしてください' }
  geocoded_by :address
  after_validation :geocode

  # 表示用のリサイズ済み画像を返す
  def display_image
    images.first.variant(resize_to_limit: [500, 500])
  end

  def self.ransackable_attributes(auth_object = nil)
    ["address", "available_time", "content", "created_at", "fee", "holiday", "id", "latitude", "longitude", "name", "phone_number", "updated_at", "url", "user_id"]
  end
end
