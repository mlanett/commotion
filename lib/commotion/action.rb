require "commotion"

class Commotion::Action

  include Commotion
  include Utilities

  def initialize( document )
    @document = symbolize(document)
  end

  def method_missing( key, *arguments )
    if key =~ /^(.*)=$/ then
      return @document[ $1.to_sym ] = arguments.first if arguments.size == 1
    else
      return @document[key] if arguments.size == 0
    end
    super
  end

  def to_s
    @document.to_s
  end

  def inspect
    "Action(#{to_s})"
  end

end
