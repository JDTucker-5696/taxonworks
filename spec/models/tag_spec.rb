require 'rails_helper'

describe Tag, type: :model, group: [:annotators, :tags] do

  let(:tag) { Tag.new }
  let(:keyword) { Keyword.create(name: 'Keyword for model test', definition: 'Only used here') }
  let(:otu) { FactoryGirl.create(:valid_otu) }

  context 'associations' do
    specify 'tag_object' do 
      expect(tag.tag_object = FactoryGirl.create(:valid_biocuration_class)).to be_truthy
    end

    specify 'keyword' do
      expect(tag.keyword = FactoryGirl.create(:valid_keyword, name: 'tag association keyword')).to be_truthy
    end
  end

  context 'validation' do
    before(:each) do
      tag.valid?
    end

    specify 'a keyword is required' do
      expect(tag.errors.include?(:keyword)).to be_truthy
    end

    specify 'a topic can not be used' do
      t = Topic.new(definition: 'Something about foo', name: 'not a topic')
      expect{tag.keyword = t}.to raise_error(ActiveRecord::AssociationTypeMismatch)
    end

    context 'keyword uniqueness per object' do
      let(:k) { FactoryGirl.create(:valid_keyword, name: 'some unique keyword') }

      specify 'a tagged object is only tagged once per keyword' do
        tag.tag_object = otu
        tag.keyword = k
        tag.valid?
        expect(tag.errors.include?(:keyword)).to be_falsey
        expect(tag.errors.include?(:tag_object)).to be_falsey
        tag.save!
        dupe_tag = FactoryGirl.build(:tag, keyword: k, tag_object: otu)
        dupe_tag.valid?
        expect(dupe_tag.errors.include?(:keyword_id)).to be_truthy
      end

      specify 'a tagged object is only tagged once per keyword using nested attributes' do
        expect(otu.update(tags_attributes: [{keyword: k}, {keyword: k}])).to be_falsey
      end
    end

    specify 'keywords scope can be limited with Keyword#can_tag' do
      a = FactoryGirl.create(:valid_biocuration_group)
      b = FactoryGirl.create(:valid_specimen)
      t = Tag.new(tag_object: b, keyword: a)
      expect(t.valid?).to be_falsey
      expect(t.errors.include?(:keyword)).to be_truthy
    end

    specify 'tag_object class can be limited with TagObject#taggable_with' do
      a = FactoryGirl.create(:valid_keyword, name: 'some limited keyword')
      b = FactoryGirl.create(:valid_biocuration_class)
      t = Tag.new(tag_object: b, keyword: a)
      expect(t.valid?).to be_falsey
      expect(t.errors.include?(:tag_object)).to be_truthy
    end
  end

  context 'STI based tag behaviour' do
    before(:each) {
      tag.keyword = FactoryGirl.create(:valid_keyword, name: 'some sti keyword') 
      tag.tag_object = FactoryGirl.create(:valid_specimen)
    }

    specify 'tagging an subclass of an STI model instance *stores* the tag_type as the superclass' do
      expect(tag.save).to be_truthy
      expect(tag.tag_object_type).to eq('CollectionObject')
    end

    specify 'tagging an subclass of an STI model instance, with subclass namespace, *stores* the tag_type as the superclass' do
      tag.tag_object = FactoryGirl.create(:valid_container_box)
      expect(tag.save).to be_truthy
      expect(tag.tag_object_type).to eq('Container')
    end

    specify 'tagging a subclass of an STI model *returns* the subclassed object' do
      expect(tag.save).to be_truthy
      expect(tag.tag_object.class).to eq(Specimen) 
    end
  end

  context 'acts_as_list' do
    specify 'position is set' do
      t1 = FactoryGirl.create(:valid_tag)
      expect(t1.position).to eq(1)
    end
  end

  context 'global ids/entity' do
    before {
      tag.tag_object_global_entity = otu.to_global_id
      tag.keyword = keyword
      tag.save!
    }

    specify 'tag_object can be set by global_id' do
      expect(tag.tag_object).to eq(otu)
    end

    specify 'tag_object_global_entity can be returned' do
      expect(tag.tag_object_global_entity).to eq(otu.to_global_id)
    end
  end

  context 'keyword nested attributes' do 
    let(:o) { Otu.new(
      name: 'Some otu', 
      tags_attributes: [ 
        { keyword_attributes: 
          {name: 'untouched keyword',  
           definition: 'not bar'}} ]) 
    }

    specify 'keyword can be created' do
      expect(o.save).to be_truthy
      expect(o.keywords.count).to eq(1)
      expect(Tag.count).to eq(1) 
      expect(Keyword.count).to eq(1) 
    end

    specify 'when tag is destroyed keyword is left' do
      expect(o.save).to be_truthy
      o.tags.destroy_all
      expect(o.tags.count).to eq(0)
      expect(o.keywords.count).to eq(0)
      expect(Keyword.first.name).to eq('untouched keyword')
    end

    context 'keyword can be referenced' do
      specify 'by id' do
        o1 = Otu.new(name: 'Other otu', tags_attributes: [ {keyword_id: keyword.id} ])
        expect(o1.save).to be_truthy
        expect(o1.keywords).to contain_exactly(keyword)
      end

      specify 'by object' do
        o1 = Otu.new(name: 'Other otu', tags_attributes: [ {keyword: keyword} ])
        expect(o1.save).to be_truthy
        expect(o1.keywords).to contain_exactly(keyword)
      end
    end

    context 'duplication' do
      let(:name)       { 'bad_keyword' }
      let(:definition) { 'bad_definition'}
      let(:keyword_params) { { name: name, definition: definition } }

      context 'by identical params' do 
        let(:dupe_param_otu) {
          Otu.new(name: 'Other otu', tags_attributes: [
            {keyword_attributes: keyword_params}, 
            {keyword_attributes: keyword_params}
          ])
        }

        specify 'duplicate new keywords are rejected' do
          expect(dupe_param_otu.valid?).to be_falsey
        end
      end

      context 'by reference to id/object that are the same' do
        let(:dupe_tag_otu) {
          Otu.new(
            name: 'Other otu', 
            tags_attributes: [ 
              {keyword: keyword},
              {keyword_id: keyword.id}
            ])
        }

        specify 'duplicate existing keywords are rejected' do
          k = Keyword.create(name: 'a111', definition: 'a111')
          otu =
            Otu.new(
                name: 'Other otu',
                tags_attributes: [
                    {keyword: k},
                    {keyword_id: k.id}
                ])
#          expect(otu.tags.to_a.count).to eq(2)
#          expect(otu.tags[0].keyword.attributes).to eq(k.attributes)
#          expect(otu.tags[1].keyword.attributes).to eq(k.attributes)
          expect(otu.valid?).to be_falsey
#          expect(dupe_tag_otu.valid?).to be_falsey
        end
      end
    
    end
  end

  context 'concerns' do
    it_behaves_like 'is_data'
  end

end

