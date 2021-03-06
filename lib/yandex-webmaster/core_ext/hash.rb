# encoding: utf-8

class Hash # :nodoc:
  def except(*items) # :nodoc:
    self.dup.except!(*items)
  end unless method_defined?(:except)

  def except!(*keys) # :nodoc:
    copy = self.dup
    keys.each { |key| copy.delete!(key) }
    copy
  end unless method_defined?(:except!)

  def slice(*keys)
    keys = keys.map! { |key| convert_key(key) } if respond_to?(:convert_key, true)
    hash = self.class.new
    keys.each { |k| hash[k] = self[k] if has_key?(k) }
    hash
  end unless method_defined?(:slice)

  def slice!(*keys)
    keys = keys.map! { |key| convert_key(key) } if respond_to?(:convert_key, true)
    omit = slice(*self.keys - keys)
    hash = slice(*keys)
    replace(hash)
    omit
  end unless method_defined?(:slice!)

  def serialize # :nodoc:
    self.map { |key, val| [key, val].join("=") }.join("&")
  end unless method_defined?(:serialize)

  def all_keys # :nodoc:
    keys = self.keys
    keys.each do |key|
      if self[key].is_a?(Hash)
        keys << self[key].all_keys.compact.flatten
        next
      end
    end
    keys.flatten
  end unless method_defined?(:all_keys)

  def has_deep_key?(key)
    self.all_keys.include? key
  end unless method_defined?(:has_deep_key?)

  def self.hash_traverse(hash, &block)
    hash.each do |key, val|
      block.call(key)
      case val
      when Hash
        val.keys.each do |k|
          _hash_traverse(val, &block)
        end
      when Array
        val.each do |item|
          _hash_traverse(item, &block)
        end
      end
    end
    return hash
  end  
end # Hash
