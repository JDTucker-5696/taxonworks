json.extract! citation, :id, :citation_object_id, :citation_object_type, :source_id, :pages, :is_original, :created_by_id, :updated_by_id, :project_id
json.citation_object_tag object_tag(citation.citation_object)
json.url citation_url(citation, format: :json)
json.object_tag citation_tag(citation)

json.citation_topics do |ct|
  ct.array! citation.citation_topics, partial: '/citation_topics/attributes', as: :citation_topic
end

json.source do
  json.partial! '/sources/attributes', source: citation.source 

  if citation.source.is_bibtex?
    json.author_year citation.source.author_year
  end
end

