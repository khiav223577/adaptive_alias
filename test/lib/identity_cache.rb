require 'identity_cache'

class MockedCacheStore
  def initialize
    @cache = {}
  end

  def delete(key)
    @cache.delete(key)
  end

  def read(key)
    @cache[key]
  end

  def write(key, value)
    @cache[key] = value
  end
end

IdentityCache.cache_backend = MockedCacheStore.new
IdentityCache.logger = Logger.new(nil)
