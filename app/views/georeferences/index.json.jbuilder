json.array!(@georeferences) do |georeference|
  json.extract! georeference, :id, :geographic_item_id, :collecting_event_id, :error_radius, :error_depth, :error_geographic_item_id, :type, :position, :is_public, :api_request, :created_by_id, :updated_by_id, :project_id, :is_undefined_z, :is_median_z
  json.url georeference_url(georeference, format: :json)
end
