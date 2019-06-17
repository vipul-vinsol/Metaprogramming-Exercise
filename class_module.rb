module ClassModule

  def action_methods(*args)
    if args.any? { |ele| public_method_defined?(ele) }
      args.each do |m_sym|
        temp_method = instance_method(m_sym)
        store = get_filter_store
        define_method(m_sym) do
          store[m_sym][:before].each { |before_method| send before_method }
          temp_method.bind(self).call
          store[m_sym][:after].each { |after_method| send after_method }
        end
      end
    end
  end

  def before_filter(*args, only: nil, except: nil)
    return false unless args.all? { |ele| private_method_defined?(ele) }
    return if only && insert_filters_in_store(only, :before, args)
    filter_on_methods = filter_methods 
    except && filter_on_methods -= except
    insert_filters_in_store(filter_on_methods, :before, args)
  end

  def after_filter(*args, only: nil, except: nil)
    return false unless args.all? { |ele| private_method_defined?(ele) }
    return if only && insert_filters_in_store(only, :after, args)
    filter_on_methods = filter_methods
    except && filter_on_methods -= except
    insert_filters_in_store(filter_on_methods, :after, args)
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

  private def filter_methods
    m = class_variable_get('@@__action_methods')
    return m if m.length > 0
    public_instance_methods(false)
  end

end
