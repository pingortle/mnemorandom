# frozen_string_literal: true

require "json"
require "pathname"
require_relative "mnemorandom/version"

module Mnemorandom
  class Error < StandardError; end

  GEM_ROOT = Pathname("#{__dir__}/..")
  DATA_PATH = Pathname(GEM_ROOT.join("vendor/git/corpora.git/data"))

  def self.load_categories
    Dir.children(DATA_PATH)
  end

  def self.load_corpora(category)
    Dir.children(DATA_PATH.join(category.to_s)).map { |filename| filename.delete_suffix(".json") }
  end

  def self.load_raw_corpus(category, name)
    JSON.parse((DATA_PATH + category.to_s + "#{name}.json").read)
  end

  def self.load_smart_corpus(*args)
    load_raw_corpus(*args).values.find { |value| value.is_a?(Array) }.tap do |list|
      raise Error.new("Unsupported corpus schema detected") unless list.first.respond_to?(:to_str)
    end
  end

  class Word < Struct.new(:raw)
    def name
      raw
    end

    def <=>(other)
      name <=> other.name
    end

    class << self
      def load
        raise "not implemented"
      end

      attr_writer :words
      def words
        load
        @words
      end

      def where(max: nil)
        words.filter { |word| max.nil? ? true : word.name.length <= max }
      end
    end
  end

  module Colors
    class Crayola < Word
      def name
        @name ||= raw.fetch("color")
      end

      class << self
        def load
          self.words ||= Mnemorandom.load_raw_corpus(:colors, :crayola)
            .fetch("colors")
            .map(&method(:new))
        end
      end
    end
  end

  module Humans
    class TolkienCharacterName < Word
      def self.load
        self.words = Mnemorandom.load
      end
    end
  end
end
