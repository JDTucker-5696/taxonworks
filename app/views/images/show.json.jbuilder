# json.extract! @image, :id, :user_file_name, :height, :width, :image_file_fingerprint, :created_by_id, :project_id, :image_file_file_name, :image_file_content_type, :image_file_file_size, :image_file_updated_at, :updated_by_id, :created_at, :updated_at
json.partial! 'attributes', image: @image

