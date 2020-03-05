json.extract! controlled_vocabulary_term, :id, :type, :name, :definition, :uri, :uri_relation, :css_color, :updated_at
json.object_tag controlled_vocabulary_term_tag(controlled_vocabulary_term)
json.url controlled_vocabulary_term_url(controlled_vocabulary_term, format: :json)

json.partial! '/shared/data/all/metadata', object: controlled_vocabulary_term

if controlled_vocabulary_term.type == 'Keyword'
  json.tag_count controlled_vocabulary_term.tags.count
end
