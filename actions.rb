#!/usr/bin/env ruby

require 'csv'
require 'pp'

class CharacterActions
  CHARACTERS = './characters.csv'

  def self.print_menu
    print "\nAvailable commands:\n\n"
    print "- characters: list characters with stat blocks\n"
    print "- freeroll(character, *attributes): free roll a check against given attributes for the given character\n"
    print "- roll(character, action): roll predefined action checks for the given character\n"
    print "--- perception\n"
  end

  def self.print_characters
    pp new.characters
  end

  def self.roll(character:, attributes: [], action: nil)
    new.roll(character, attributes, action)
  end

  def initialize
    @character_data = CSV.read(CHARACTERS, headers: true)
  end

  def roll(character, attributes, action)
    natural_roll = roll_d20
    result = if natural_roll == 1
               'a critical failure'
             elsif natural_roll == 20
               'a critical success'
             else
              stats = characters.fetch(character)
              bonus = if action
                        public_send(action, stats)
                      else
                        attributes.map { |attr| stats[attr.to_sym] }.sum
                      end

               operator = bonus.negative? ? '-' : '+'
               total = natural_roll + bonus

               "#{total} (#{natural_roll} #{operator} #{bonus.abs})"
             end

    print "\n#{character.capitalize} rolled #{result}\n\n"
  end

  def perception(stats)
    ((stats[:con] + stats[:wis]) / 2).floor + stats[:explorer]
  end

  def characters
    @characters ||= character_data.inject({}) do |result, row|

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
  attr_reader :character_data

  def roll_d20
    Random.rand(1..20)
  end
end

case ARGV[0]
when 'help'
  CharacterActions.print_menu
when 'characters'
  CharacterActions.print_characters
when 'roll'
  CharacterActions.roll(character: ARGV[1], action: ARGV[2])
when 'freeroll'
  CharacterActions.roll(character: ARGV.delete_at(1), attributes: ARGV[1..-1])
else
  CharacterActions.print_menu
end
