json.extract! taxon_determination, :id, :biological_collection_object_id, :otu_id, 
  :position, :year_made, :month_made, :day_made,
  :print_label,
  :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at
json.partial! '/shared/data/all/metadata', object: taxon_determination, klass: 'TaxonDetermination'

if taxon_determination.roles.any?
  json.determiner_roles do
    json.array! taxon_determination.determiners.each do |role|
      json.extract! role, :id, :position
      json.person do
        json.partial! '/people/attributes', person: role.person 
      end
    end
  end
end 

