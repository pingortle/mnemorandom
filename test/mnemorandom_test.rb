# frozen_string_literal: true

require "test_helper"
require "set"

class MnemorandomTest < Minitest::Test
  class ColorsModuleCrayolaTest < self
    Crayola = Mnemorandom::Colors::Crayola

    def setup
      @raw_almond = {"color" => "Almond", "hex" => "#EFDECD"}
      @almond = Crayola.new(@raw_almond)
    end

    def test_word_has_a_name
      assert_equal "Almond", @almond.name
    end

    def test_can_filter_by_criteria
      assert_predicate Crayola.where(max: 5), :any?
      assert Crayola.where(max: 5).all? { |object| object.name.length <= 5 }
    end

    def test_can_sort_words
      words = Crayola.words
      assert_equal words.map(&:name).sort, words.sort.map(&:name)
    end

    def test_loads_words
      assert_operator 0, :<, Crayola.words.length
    end
  end

  def test_load_smart_corpus_raises_on_non_string_list
    assert_raises(Mnemorandom::Error) do
      Mnemorandom.load_smart_corpus(:animals, :birds_antarctica)
    end
  end

  def test_load_load_smart_corpus
    assert_set_operator ["aardvark"], :<, Mnemorandom.load_smart_corpus(:animals, :common)
    assert_set_operator ["Abyssinian"], :<, Mnemorandom.load_smart_corpus(:animals, :cats)
  end

  def test_load_corpus_by_fully_qualified_name
    result = Mnemorandom.load_raw_corpus(:animals, :common)
    assert_set_operator ["aardvark"], :<, result.dig("animals")
  end

  def test_list_corpora
    corpora = %w[
      ant_anatomy
      birds_antarctica
      birds_north_america
      cats
      cephalopod_anatomy
      collateral_adjectives
      common
      dinosaurs
      dog_names
      dogs-en-de
      dogs
      donkeys
      horses
      ponies
      rabbits
    ]
    assert_set_equal corpora, Mnemorandom.load_corpora(:animals)
  end

  def test_list_categories
    categories = %w[
      animals
      archetypes
      architecture
      art
      books
      colors
      corporations
      divination
      film-tv
      foods
      games
      geography
      governments
      humans
      instructions
      materials
      mathematics
      medicine
      music
      mythology
      objects
      plants
      psychology
      religion
      science
      societies_and_groups
      sports
      technology
      transportation
      travel
      words
    ]
    assert_set_equal categories, Mnemorandom.load_categories
  end

  def assert_set_equal(expected, actual)
    assert_equal expected.to_set, actual.to_set
  end

  def assert_set_operator(expected, operator, actual)
    assert_operator expected.to_set, operator, actual.to_set
  end
end
