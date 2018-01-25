# TypeMaterial links CollectionObjects to Protonyms.  It is the single direct relationship between nomenclature and collection objects in TaxonWorks (all other name/collection object relationships coming through OTUs).
# TypeMaterial is based on specific rules of nomenclature, it only includes those types (e.g. "holotype") that are specifically goverened (e.g. "topotype" is not allowed).
#
# @!attribute protonym_id
#   @return [Integer]
#     the protonym in question
#
# @!attribute biological_object_id
#   @return [Integer]
#     the CollectionObject
#
# @!attribute type_type
#   @return [String]
#     the type of Type relationship (e.g. holotype)
#
# @!attribute project_id
#   @return [Integer
#   the project ID
#
# @!attribute position
#   @return [Integer]
#    sort column
#
class TypeMaterial < ApplicationRecord
  include Housekeeping
  include Shared::Citations
  include Shared::DataAttributes
  include Shared::HasRoles
  include Shared::Identifiers
  include Shared::IsData
  include Shared::Notes
  include Shared::Tags
  include SoftValidation

  # Keys are valid values for type_type, values are
  # required Class for material
  ICZN_TYPES = {
    'holotype' =>  Specimen,
    'paratype' => Specimen,
    'paralectotype' => Specimen,
    'neotype' => Specimen,
    'lectotype' => Specimen,
    'syntype' => Specimen,
    'paratypes' => Lot,
    'syntypes' => Lot,
    'paralectotypes' => Lot
  }.freeze

  ICN_TYPES = {
      'holotype' => Specimen,
      'paratype' => Specimen,
      'lectotype' => Specimen,
      'neotype' => Specimen,
      'epitype' => Specimen,
      'isotype' => Specimen,
      'syntype' => Specimen,
      'isosyntype' => Specimen,
      'syntypes' => Lot,
      'isotypes' => Lot,
      'isosyntypes' => Lot
  }.freeze

  belongs_to :material, foreign_key: :biological_object_id, class_name: 'CollectionObject', inverse_of: :type_designations
  belongs_to :protonym
  has_many :type_designator_roles, class_name: 'TypeDesignator', as: :role_object
  has_many :type_designators, through: :type_designator_roles, source: :person

  accepts_nested_attributes_for :type_designators, :type_designator_roles, allow_destroy: true
  accepts_nested_attributes_for :material, allow_destroy: true

  scope :where_protonym, -> (taxon_name) { where(protonym_id: taxon_name) }
  scope :with_type_string, -> (base_string) { where('type_type LIKE ?', "#{base_string}" ) }
  scope :with_type_array, -> (base_array) { where('type_type IN (?)', base_array ) }

  scope :primary, -> {where(type_type: %w{neotype lectotype holotype}).order('biological_object_id')}
  scope :syntypes, -> {where(type_type: %w{syntype syntypes}).order('biological_object_id')}

  #  scope :primary_with_protonym_array, -> (base_array) {select('type_type, source_id, biological_object_id').group('type_type, source_id, biological_object_id').where("type_materials.type_type IN ('neotype', 'lectotype', 'holotype', 'syntype', 'syntypes') AND type_materials.protonym_id IN (?)", base_array ) }

  scope :primary_with_protonym_array, -> (base_array) {select('type_type, biological_object_id').group('type_type, biological_object_id').where("type_materials.type_type IN ('neotype', 'lectotype', 'holotype', 'syntype', 'syntypes') AND type_materials.protonym_id IN (?)", base_array ) }

  soft_validate(:sv_single_primary_type, set: :single_primary_type)
  soft_validate(:sv_type_source, set: :type_source)

  validates :protonym, presence: true
  validates :material, presence: true
  validates_presence_of :type_type

  validate :check_type_type
  validate :check_protonym_rank

  # TODO: really should be validating uniqueness at this point, it's type material, not garbage records

  def type_source
    [source, protonym.try(:source), nil].compact.first
  end

  def legal_type_type(code, type_type)
    case code
    when :iczn
      ICZN_TYPES.keys.include?(type_type)
    when :icn
      ICZN_TYPES.keys.include?(type_type)
    else
      false
    end
  end

  protected

  def check_type_type
    if protonym
      code = protonym.rank_class.nomenclatural_code
      errors.add(:type_type, 'Not a legal type for the nomenclatural code provided') if !legal_type_type(code, type_type)
    end
  end

  def check_protonym_rank
    errors.add(:protonym_id, 'Type cannot be designated, name is not a species group name') if protonym && !protonym.is_species_rank?
  end

  def sv_single_primary_type

    primary_types = TypeMaterial.with_type_array(['holotype', 'neotype', 'lectotype']).where_protonym(protonym).not_self(self)
    syntypes = TypeMaterial.with_type_array(['syntype', 'syntypes']).where_protonym(protonym)

    if type_type =~ /syntype/
      soft_validations.add(:type_type, 'Other primary types selected for the taxon are conflicting with the syntypes') unless primary_types.empty?
    end

    if ['holotype', 'neotype', 'lectotype'].include?(type_type)
      soft_validations.add(:type_type, 'More than one primary type associated with the taxon') if !primary_types.empty? || !syntypes.empty?
    end
  end

  def sv_type_source
    soft_validations.add(:base, 'Source is not selected neither for type nor for taxon') unless type_source
  end

end
