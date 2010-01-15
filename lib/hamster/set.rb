require 'forwardable'

require 'hamster/tuple'
require 'hamster/trie'
require 'hamster/list'

module Hamster

  def self.set(*items)
    items.reduce(Set.new) { |set, item| set.add(item) }
  end

  class Set

    extend Forwardable

    def initialize(trie = Trie.new)
      @trie = trie
    end

    def empty?
      @trie.empty?
    end
    def_delegator :self, :empty?, :null?

    def size
      @trie.size
    end
    def_delegator :self, :size, :length

    def include?(item)
      @trie.has_key?(item)
    end
    def_delegator :self, :include?, :member?
    def_delegator :self, :include?, :contains?
    def_delegator :self, :include?, :elem?

    def add(item)
      if include?(item)
        self
      else
        self.class.new(@trie.put(item, nil))
      end
    end
    def_delegator :self, :add, :<<

    def delete(key)
      trie = @trie.delete(key)
      if trie.equal?(@trie)
        self
      else
        self.class.new(trie)
      end
    end

    def each
      return self unless block_given?
      @trie.each { |entry| yield(entry.key) }
    end
    def_delegator :self, :each, :foreach

    def map
      return self unless block_given?
      if empty?
        self
      else
        self.class.new(@trie.reduce(Trie.new) { |trie, entry| trie.put(yield(entry.key), nil) })
      end
    end
    def_delegator :self, :map, :collect

    def reduce(memo)
      return memo unless block_given?
      @trie.reduce(memo) { |memo, entry| yield(memo, entry.key) }
    end
    def_delegator :self, :reduce, :inject
    def_delegator :self, :reduce, :fold

    def filter
      return self unless block_given?
      trie = @trie.filter { |entry| yield(entry.key) }
      if trie.equal?(@trie)
        self
      else
        self.class.new(trie)
      end
    end
    def_delegator :self, :filter, :select
    def_delegator :self, :filter, :find_all

    def remove
      return self unless block_given?
      filter { |item| !yield(item) }
    end
    def_delegator :self, :remove, :reject
    def_delegator :self, :remove, :delete_if

    def any?
      return any? { |item| item } unless block_given?
      each { |item| return true if yield(item) }
      false
    end
    def_delegator :self, :any?, :exist?
    def_delegator :self, :any?, :exists?

    def all?
      return all? { |item| item } unless block_given?
      each { |item| return false unless yield(item) }
      true
    end
    def_delegator :self, :all?, :forall?

    def none?
      return none? { |item| item } unless block_given?
      each { |item| return false if yield(item) }
      true
    end

    def find
      return nil unless block_given?
      each { |item| return item if yield(item) }
      nil
    end
    def_delegator :self, :find, :detect

    def partition(&block)
      return self unless block_given?
      Tuple.new(filter(&block), reject(&block))
    end

    def grep(pattern, &block)
      filter { |item| pattern === item }.map(&block)
    end

    def count(&block)
      filter(&block).size
    end

    def head
      find { true }
    end
    def_delegator :self, :head, :first

    def product
      reduce(1, &:*)
    end

    def sum
      reduce(0, &:+)
    end

    def sort(&block)
      to_list.sort(&block)
    end

    def sort_by(&block)
      to_list.sort_by(&block)
    end

    def join(sep = nil)
      to_a.join(sep)
    end

    def compact
      remove(&:nil?)
    end

    def eql?(other)
      other.is_a?(self.class) && @trie.eql?(other.instance_eval{@trie})
    end
    def_delegator :self, :eql?, :==

    def dup
      self
    end
    def_delegator :self, :dup, :clone
    def_delegator :self, :dup, :uniq
    def_delegator :self, :dup, :nub
    def_delegator :self, :dup, :to_set
    def_delegator :self, :dup, :remove_duplicates

    def to_a
      reduce([]) { |a, item| a << item }
    end
    def_delegator :self, :to_a, :entries

    def to_list
      reduce(EmptyList) { |list, item| list.cons(item) }
    end

    def inspect
      "{#{to_a.inspect[1..-2]}}"
    end

  end

end
