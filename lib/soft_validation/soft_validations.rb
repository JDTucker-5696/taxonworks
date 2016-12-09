
module SoftValidation

 # A SoftValidations instance contains a set of SoftValidations
  # and some code that tracks whether those validations have
  # been fixed, etc.
  #
  # @!attribute soft_validations
  #   @return [Array]
  #   the set of SoftValidations (i.e. problems with a record/instance)
  # @!attribute instance 
  #   the object being validated, an instance of an ActiveRecord model 
  # @!attribute validated 
  #   @return [Boolean] 
  #   True if the soft validations methods have been called.
  # @!attribute fixed
  #   @return [Symbol]
  #   True if fix() has been called. Note that this does not imply that all SoftValidations have been fixed!
  class SoftValidations
    attr_accessor :soft_validations, :instance, :validated, :fixes_run

    # @param[ActiveRecord] a instance of some ActiveRecord model
    def initialize(instance)
      @validated = false
      @fixes_run = false
      @instance = instance # Klass from here
      @soft_validations = []
    end

    # @param [Symbol] attribute a column attribute or :base
    # @param [String] message a message describing the soft validation to the user, i.e. what has gone wrong
    # @param [Hash{fix: :method_name, success_message: String, failure_message: String }] options the method identified by :fix should fully resolve the SoftValidation. 
    def add(attribute, message,  options = {}) # index = nil
      # TODO: Stub a generic TW Error and raise it instead
      raise "can not add soft validation to [#{attribute}] - not a column name or 'base'" if !(['base'] + instance.class.column_names).include?(attribute.to_s)
      raise "invalid :fix_trigger" if !options[:fix_trigger].blank? && ![:all, :automatic, :requested].include?(options[:fix_trigger])
      return false if attribute.nil? || message.nil? || message.length == 0
      return false if (options[:success_message] || options[:failure_message]) && !options[:fix]

      sv = SoftValidation.new() 
      
      sv.attribute = attribute 
      sv.message = message

      sv.fix_trigger = options[:fix_trigger]
      sv.fix = options[:fix]
      sv.success_message = options[:success_message] 
      sv.failure_message = options[:failure_message] 

      sv.fix_trigger ||= :automatic

      @soft_validations << sv
    end

 #  def soft_validations(scope = :all)
 #    set = ( scope == :all ? [:automatic, :requested] : [scope] )
 #    @soft_validations.select{|v| set.include?(v.fix_trigger)}
 #  end

    # @return [Boolean]
    #   soft validations have been run
    def validated?
      @validated
    end

    def resolution_for(method)
      self.instance.class.soft_validation_methods[self.instance.class.name][method].resolution
    end

    # @return [Boolean]
    #   fixes on resultant soft validations have been run
    def fixes_run?
      @fixes_run
    end

    # @return [Boolean]
    #   soft validations run and none were generated 
    def complete?
      validated? && soft_validations.count == 0 
    end

    # @return [Hash<attribute><Array>]
    #   a hash listing the results of the fixes 
    def fix_messages
      messages = {}
      if fixes_run?
        soft_validations.each do |v| 
          messages[v.attribute] ||= []
          messages[v.attribute] << (v.result_message) 
        end
      end
      messages
    end

    def on(attribute)
      soft_validations.select{|v| v.attribute == attribute} 
    end

    def messages
      soft_validations.collect{ |v| v.message}
    end

    def messages_on(attribute)
      on(attribute).collect{|v| v.message}
    end
  end

end 


