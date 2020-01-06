require 'rails_helper'
require 'catalog/nomenclature/entry'

describe Catalog::Nomenclature::Entry, group: [:catalogs, :nomenclature_catalog, :nomenclature], type: :spinup do

  let(:root) { Project.find(Current.project_id).send(:create_root_taxon_name) }
  let(:genus) { Protonym.create!(parent: root, name: 'Aus', rank_class: Ranks.lookup(:iczn, :genus) )}
  let!(:c1) { FactoryBot.create(:valid_citation, citation_object: genus) }
  let(:catalog_entry) { Catalog::Nomenclature::Entry.new(genus) }

  specify '#items' do
    expect(catalog_entry.items.count).to eq(1)
  end

  specify '#all_sources' do
    expect(catalog_entry.send(:all_sources)).to contain_exactly(c1.source)
  end   

  specify '#sources' do
    expect(catalog_entry.sources).to contain_exactly(c1.source) 
  end

end
