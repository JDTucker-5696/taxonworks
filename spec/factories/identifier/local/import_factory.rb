# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :identifier_local_import, class: 'Identifier::Local::Import', traits: [:housekeeping] do
  end
end
