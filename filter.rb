require './class_module.rb'

module Filters
  def self.included(klass)
    klass.class_variable_set('@@__filter_store', Hash.new { |h,k| h[k] = {'before': [], 'after': []} })
    klass.class_variable_set('@@__action_methods', [])
    klass.extend ClassModule
  end
end
