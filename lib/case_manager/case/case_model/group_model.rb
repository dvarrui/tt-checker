
require_relative 'target_model'

class CaseModel
  class GroupModel
    attr_accessor :name
    attr_reader :targets
    
    def initialize(name)
      @name = name
      @targets = []
      @current_target = nil
    end

    def target
      @current_target
    end

    def target_new(description, args={})
      @current_target = TargetModel.new(description,args)
      @targets << @current_target
    end
  end
end
