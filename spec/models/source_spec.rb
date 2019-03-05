require 'rails_helper'

describe Source, type: :model, group: :source do
  let(:source) { Source.new }
  let(:string1) { 'This is a base string.' }
  let!(:s1) { FactoryBot.create(:valid_source_verbatim, verbatim: string1) }
  let(:s1a) {
    s = s1.dup
    s.save!
    s
  }
  let!(:s3) { FactoryBot.create(:valid_source_verbatim, verbatim: 'This is a roof string.') }
  let!(:s2) { FactoryBot.create(:valid_source_verbatim, verbatim: string1) }
  let!(:s4) { FactoryBot.create(:valid_source_verbatim, verbatim: 'This is a r00f string.') }

  after(:all) {
    Source.destroy_all
  }

  specify '#is_in_project? 1' do
    expect(source.is_in_project?(1)).to be_falsey
  end

  context 'associations' do
    specify '#citations' do
      expect(source.citations << Citation.new()).to be_truthy
    end
  end

  context 'cited objects' do
    let(:o) { FactoryBot.create(:valid_otu) }
    let(:a) { FactoryBot.create(:valid_source_bibtex) }

    specify 'returns a scope' do
      expect(source.cited_objects).to eq([])
    end

    specify 'returns a mixed array of objects' do
      Citation.create!(source: a, citation_object: o)
      a.reload
      expect(a.cited_objects.include?(o)).to be_truthy
    end
  end

  context 'fuzzy matching' do

    specify '#nearest_by_levenshtein(compared_string, column, limit) 1' do
      expect(s1.nearest_by_levenshtein(s1.verbatim, :cached).first).to eq(s2)
    end

    specify '#nearest_by_levenshtein 2' do
      expect(s2.nearest_by_levenshtein(s2.verbatim, :cached).first).to eq(s1)
    end

    specify '#nearest_by_levenshtein 3' do
      expect(s3.nearest_by_levenshtein(s3.verbatim, :cached).first).to eq(s4)
    end

    specify '#nearest_by_levenshtein 4' do
      expect(s4.nearest_by_levenshtein(s4.verbatim, :cached).first).to eq(s3)
    end
  end

  context 'concerns matching' do
    context 'instance methods' do
      context '#identical' do
        specify 'full matching' do
          # duplicate record
          [s1a]
          expect(s1.identical.ids).to contain_exactly(s1a.id, s2.id)
        end
      end

      context '#similar' do
        specify 'full matching' do
          # duplicate record
          [s1a]
          expect(s1.similar.ids).to contain_exactly(s1a.id, s2.id)
        end
      end
    end

    context 'class methods' do
      context '#identical' do
        specify 'full matching' do
          # duplicate record
          [s1a]
          expect(Source.identical(s1.attributes).ids).to contain_exactly(s1.id, s1a.id, s2.id)
        end
      end

      context '#similar' do
        specify 'full matching' do
          # duplicate record
          [s1a]
          expect(Source.similar(s1.attributes).ids).to contain_exactly(s1a.id, s2.id, s1.id)
        end
      end
    end
  end

  context 'duplicate record tests' do
=begin
    Species File conventions to remember:
      Two references are considered a match even if access code or th3 editor, OSF copy, or citation flags are different.
      Two references are considered different if they have different verbatim reference fields
        (including different capitalization), even if everything else matches!
      A reference is considered different if author, pub or containing ref aren't identical
      A reference is considered similar if years, title, volume or pages are either the same or missing.
      a similar reference may be added to the db by user request
      the values of verbatim data are ignored when checking if references are similar.
=end
    # xspecify 'find an identical record'
    # xspecify 'find a similar record'
  end

  context 'validate' do
    specify 'year_suffix' do
      source1 = FactoryBot.create(:soft_valid_bibtex_source_article, year: 1999, year_suffix: 'a')
      person1 = Person.create(last_name: 'Smith', first_name: 'Jones')
      source1.author_roles.create(person: person1)
      source2 = FactoryBot.build(:soft_valid_bibtex_source_article, year: 1999, year_suffix: nil)
      source2.author_roles.build(person: person1)
      
      expect(source2.valid?).to be_truthy
      source2.update(year_suffix: 'b')

      expect(source2.valid?).to be_truthy
      source2.update(year_suffix: 'a')

      expect(source2.valid?).to be_falsey
    end

    specify 'year suffix different authors' do
      source1 = FactoryBot.create(:soft_valid_bibtex_source_article, year: 1999, year_suffix: 'a', author: nil)
      person1 = Person.create(last_name: 'Smith', first_name: 'Jones')
      source1.author_roles.create(person: person1)
      source2 = FactoryBot.build(:soft_valid_bibtex_source_article, year: 1999, year_suffix: nil, author: nil)
      person2 = Person.create(last_name: 'Smith', first_name: 'Chris')
      source2.author_roles.build(person: person2)
      expect(source2.valid?).to be_truthy
      source2.year_suffix = 'b'
      expect(source2.valid?).to be_truthy
      source2.year_suffix = 'a'
      expect(source2.valid?).to be_truthy
    end
  end

  specify '#verbatim_contents is not trimmed' do
    s = " asdf sd  \n  asdfd \r\n" 
    source.verbatim_contents = s
    source.valid?
    expect(source.verbatim_contents).to eq(s)
  end

  context 'concerns' do
    it_behaves_like 'alternate_values'
    it_behaves_like 'data_attributes'
    it_behaves_like 'has_roles'
    it_behaves_like 'identifiable'
    it_behaves_like 'notable'
    it_behaves_like 'taggable'
    it_behaves_like 'is_data'
    it_behaves_like 'documentation'
  end

end
