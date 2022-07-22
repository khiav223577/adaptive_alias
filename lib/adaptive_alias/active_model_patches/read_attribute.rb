require 'active_record'

module ActiveRecord::AttributeMethods::Read
  def read_attribute(attr_name, &block) # :nodoc:
    name = attr_name.to_s
    name = self.class.attribute_aliases[name] || name

    name = @primary_key if name == 'id' && @primary_key
    _read_attribute(name, &block)
  end

  def _read_attribute(attr_name, &block) # :nodoc:
    name = attr_name.to_s
    name = self.class.attribute_aliases[name] || name

    sync_with_transaction_state if @transaction_state&.finalized?
    return yield if block_given? && !@attributes.key?(name)
    @attributes.fetch_value(name, &block)
  end
end
