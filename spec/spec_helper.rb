$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require 'dotenv'
Dotenv.load
require 'byebug'
require "freestyle_libre"

module Kernel
  alias_method :old_puts, :puts
  def puts(msg)
    old_puts(msg) unless msg == "A kext with the specified name already exists."
  end
end
