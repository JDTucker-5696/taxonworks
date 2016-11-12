FactoryGirl.define do
  factory :data_attribute_import_attribute, class: ImportAttribute, traits: [:creator_and_updater] do
    factory :valid_data_attribute_import_attribute  do
      import_predicate { Faker::Lorem.words(2).join(" ") }
      value { Faker::Number.number(5) }
      association :attribute_subject, factory: :valid_otu
    end
  end
end
