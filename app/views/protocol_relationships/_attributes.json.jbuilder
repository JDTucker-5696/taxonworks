json.extract! protocol_relationship, :id, :protocol_id, :protocol_relationship_object, :position, :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at
json.object_tag protocol_relationship_tag(protocol_relationship)
json.url protocol_relationship_url(protocol_relationship, format: :json)
