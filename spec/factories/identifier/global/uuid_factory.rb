# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :identifier_global_uuid, class: 'Identifier::Global::Uuid', traits: [:housekeeping] do
  end
end
