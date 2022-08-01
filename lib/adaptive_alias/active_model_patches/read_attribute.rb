require 'active_record'

module ActiveRecord::AttributeMethods::Read
  def read_attribute(attr_name, &block) # :nodoc:
    name = attr_name.to_s
    name = self.class.attribute_aliases[name] || name

    name = @primary_key if name == 'id' && @primary_key
    _read_attribute(name, &block)
  end

  # This method exists to avoid the expensive primary_key check internally, without
  # breaking compatibility with the write_attribute API
  def _read_attribute(attr_name, &block) # :nodoc:
    name = attr_name.to_s
    name = self.class.attribute_aliases[name] || name

    sync_with_transaction_state if @transaction_state&.finalized?
    return yield if block_given? and AdaptiveAlias.missing_value?(@attributes, self.class, name)
    return @attributes.fetch_value(name, &block)
  end
end
