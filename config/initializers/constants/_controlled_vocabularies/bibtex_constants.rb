# these are the bibtex fields that TW will support
# TODO Check if the capitals need to be converted to lower case?
# ToDo may need verbatim added to the list below.
BIBTEX_FIELDS = [
    :address,
    :annote,
    :author,
    :booktitle,
    :chapter,
    :crossref,
    :edition,
    :editor,
    :howpublished,
    :institution,
    :journal,
    :key,
    :month,
    :note,
    :number,
    :organization,
    :pages,
    :publisher,
    :school,
    :series,
    :title,
    :volume,
    :year,
    :url,
    :isbn,
    :issn,
    :abstract,
    :verbatim_keywords, #was keywords
    :copyright,
    :language,
    :stated_year,
    :bibtex_type
].freeze

#    :lccn,
# :price,
# :contents,

# The following lists are from http://rubydoc.info/gems/bibtex-ruby/2.3.4/BibTeX/Entry
VALID_BIBTEX_TYPES = %w{
      article
      book
      booklet
      conference
      inbook
      incollection
      inproceedings
      manual
      mastersthesis
      misc
      phdthesis
      proceedings
      techreport
      unpublished}.freeze

VALID_BIBTEX_MONTHS = %w{
  jan
  feb
  mar
  apr
  may
  jun
  jul
  aug
  sep
  oct
  nov
  dec}.freeze
