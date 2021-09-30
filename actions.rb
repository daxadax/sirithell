#!/usr/bin/env ruby

require 'csv'
require 'pp'

class CharacterActions
  CHARACTERS = './characters.csv'

  def self.print_characters
    pp new.characters
  end

  def self.roll(action, character)
    new.roll(action, character)
  end

  def initialize
    @data = CSV.read(CHARACTERS, headers: true)
  end

  def roll(action, character)
    stats = characters.fetch(character)

    natural_roll = roll_d20
    bonus = public_send(action, stats)
    total = natural_roll + bonus

    result = if natural_roll == 1
               'a critical failure'
             elsif natural_roll == 20
               'a critical success'
             else
               "#{total} (#{natural_roll} + #{bonus})"
             end

    print "\n#{character.capitalize} rolled #{result} for #{action}\n\n"
  end

  def perception(stats)
    ((stats[:con] + stats[:wis]) / 2).floor + stats[:explorer]
  end

  def characters
    @characters ||= data.inject({}) do |result, row|

      result[row['name']] = {
        str: row['str'],
        dex: row['dex'],
        con: row['con'],
        int: row['int'],
        wis: row['wis'],
        cha: row['cha'],
        fighter: row['fig'],
        rogue: row['rog'],
        explorer: row['exp'],
        sage: row['sag'],
        artist: row['art'],
        diplomat: row['dip'],
      }.transform_values(&:to_i)

      result
    end
  end

  private
  attr_reader :data

  def roll_d20
    Random.rand(1..20)
  end
end

# CharacterActions.print_characters
CharacterActions.roll(ARGV[0], ARGV[1])

