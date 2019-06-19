module ClassModule

  def action_methods(*args)
    args.any? { |ele| public_method_defined?(ele) } && args.each do |m_sym|
      temp_method = instance_method(m_sym)
      store = get_filter_store
      define_method(m_sym) do
        store[m_sym][:before].each { |before_method| send before_method }
        temp_method.bind(self).call
        store[m_sym][:after].each { |after_method| send after_method }
      end
    end
  end

  def before_filter(*args, only: nil, except: nil)
    validate_and_apply_filters(args, only, except, :before)
  end

  def after_filter(*args, only: nil, except: nil)
    validate_and_apply_filters(args, only, except, :after)
  end
  
  private def validate_and_apply_filters(filter, only_on, except_on, before_after)
    if filter.all? { |ele| private_method_defined?(ele) }
      apply_filters_on_methods(filter, only_on, except_on, before_after)
    end
  end
  
  private def apply_filters_on_methods(filters, only_on, except_on, before_after)
    return if only_handler(filters, only_on, before_after) 
    except_handler(filters, except_on, before_after)
  end
  
  private def only_handler(filters, only_on, before_after)
    only_on && insert_filters_in_store(only_on, before_after, filters)
  end

  private def except_handler(filters, except_on, before_after)
    applied_on = filters_applied_on 
    except_on && applied_on -= except_on
    insert_filters_in_store(applied_on, before_after, filters)
  end
  
  private def get_filter_store
    class_variable_get('@@__filter_store')
  end

  private def insert_filters_in_store(original_arr, type, filter_symbols)
    store = get_filter_store
    original_arr.each do |method|
      store[method][type].concat(filter_symbols)
    end
  end

  private def filters_applied_on
    m = class_variable_get('@@__action_methods')
    return m if m.length > 0
    public_instance_methods(false)
  end

end
