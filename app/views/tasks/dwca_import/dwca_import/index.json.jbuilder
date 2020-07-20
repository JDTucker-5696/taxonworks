json.array!(@datasets) do |dataset|
  json.id dataset.id
  json.description dataset.description
  json.type dataset.type
  json.progress dataset.progress
  json.created_at "#{time_ago_in_words(dataset.created_at)} ago"
  json.updated_at "#{time_ago_in_words(dataset.dataset_records.maximum(:updated_at))} ago"
end