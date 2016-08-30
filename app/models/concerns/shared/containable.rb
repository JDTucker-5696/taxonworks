# Shared code for objects that maybe be placed in Container(s).
#
module Shared::Containable
  extend ActiveSupport::Concern

  included do

    # A Container that is !new_record, or a container_id
    attr_accessor :contained_in

    after_save :contain, if: '!contained_in.blank?' #  || !contained_in_id.blank?'

    has_one :container_item, as: :contained_object
    has_one :parent_container_item, through: :container_item, source: :parent, class_name: 'ContainerItem'
    has_one :container, through: :parent_container_item, source: :contained_object, source_type: 'Container'
  end 

  def contain
    c = nil 
    if contained_in.is_a?(Container)
      c = contained_in
    else
      c = Container.find(contained_in)
    end

    put_in_container(c)
  end

  # @return [Boolean]
  #   true if item is placed in container, false if not
  def put_in_container(kontainer)
    return false if self.new_record? || kontainer.new_record?
    kontainer.add_container_items([self])
  end

  # @return [Array]
  #    return all Containers containing this container
  def enclosing_containers
    return [] if !contained?
    container_item.ancestors.map(&:contained_object)
  end

  # @return [True]
  #   this instance is containable
  def containable?
    true
  end

  # return [Boolean]
  #   whether this item is contained in something else
  def contained?
    !container.nil?
  end

  # return [Boolean]
  #   whether this object is contained by the passed container 
  def contained_by?(kontainer)
    enclosing_containers.include?(kontainer)
  end
  
end
