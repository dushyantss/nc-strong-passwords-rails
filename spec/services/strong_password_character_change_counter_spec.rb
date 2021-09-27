require 'rails_helper'

RSpec.describe StrongPasswordCharacterChangeCounter do
  context "#calculate_missing_character_types" do
    it "returns correct count" do
      [
        [")*&(", 3],
        ["", 3],
        [nil, 3],
        ["AAAA", 2],
        ["0123", 2],
        ["aaaa", 2],
        ["aaAA", 1],
        ["ZZ99", 1],
        ["Aa8", 0]
      ].each do |password, result|
        got = StrongPasswordCharacterChangeCounter.new(password).calculate_missing_character_types

        expect(got).to(eq(result), "For #{password} expected #{result} got #{got}")
      end
    end
  end

  context "#calculate_repetitions" do
    it "returns the count of repeated characters" do
      [
        ["", []],
        ["abcde123A", []],
        ["aa", []],
        ["aAa", []],
        ["AAAA", [4]],
        ["aaaAAA5555", [3,3,4]]
      ].each do |password, result|
        got = StrongPasswordCharacterChangeCounter.new(password).calculate_repetitions

        expect(got).to(eq(result), "For #{password} expected #{result} got #{got}")
      end
    end

    it "returns the count in the order of their occurence" do
        password = "aaaaabbbbcccccc"

        repetitions = StrongPasswordCharacterChangeCounter.new(password).calculate_repetitions

        expect(repetitions).to eq([5,4,6])
    end
  end

  context "#remove_repetitions_using_addition" do
    it "works correctly" do
      [
        [[], 4, []],
        [[3], 1, []],
        [[3, 5], 2, [3]],
        [[3, 4], 3, []],
        [[3, 4], 1, [4]],
        [[3, 3, 3], 1, [3, 3]],
        [[8], 2, [4]],
        [[3, 3], 4, []],
      ].each do |repetitions, additions, remaining_repetitions|
        got_rem_repetitions = StrongPasswordCharacterChangeCounter.new(nil).remove_repetitions_using_addition(repetitions, additions)

        expect(got_rem_repetitions).to(
          eq(remaining_repetitions),
          "expected #{repetitions} with additions #{additions} to have remaining #{remaining_repetitions}, but got #{got_rem_repetitions}"
        )
      end
    end
  end

  context "#remove_repetitions_using_removal" do
    it "works correctly" do
      [
        [[], 4, []],
        [[3], 1, []],
        [[3, 5], 2, [4]],
        [[3, 4], 3, []],
        [[3, 4], 1, [4]],
        [[3, 3, 3], 1, [3, 3]],
        [[8], 2, [6]],
        [[3, 6, 9, 8], 6, [8,8]],
        [[3, 3], 4, []],
      ].each do |repetitions, removals, remaining_repetitions|
        got_rem_repetitions = StrongPasswordCharacterChangeCounter.new(nil).remove_repetitions_using_removal(repetitions, removals)

        expect(got_rem_repetitions).to(
          eq(remaining_repetitions),
          "expected #{repetitions} with removals #{removals} to have remaining #{remaining_repetitions}, but got #{got_rem_repetitions}"
        )
      end
    end
  end

  context "#call" do
    it "should return 0 for strong passwords" do
      [
        "Aqpfk1swods",
        "QPFJWz1343439",
        "PFsHH78KSM", # Test case in problem statement is incorrect
        "AAaaBBbbCCcc11@-",
        "abcdefghijklmnO9",
        "0123456789ABCDEf",
        "00112233Aa"
      ].each do |password|
        got = StrongPasswordCharacterChangeCounter.new(password).call

        expect(got).to eq(0), "expected #{password} to return 0, got #{got}"
      end
    end

    it "should return the character count required to convert weak password into a strong password" do
      [
        ["Abc123", 4],
        ["aaaaaAAAA", 2],
        ["abcdefghijklmnop", 2],
        ["AAAfk1swods", 1],
        ["0123456789AABBCCdd", 2],
        ["", StrongPasswordCharacterChangeCounter::MIN_LEN],
        ["abcdefghijABCDEFGHIJ1234567890", 14],
        ["000aaaBBBccccDDD", 5]
      ].each do |password, count|
        got = StrongPasswordCharacterChangeCounter.new(password).call

        expect(got).to eq(count), "expected #{password} to have count #{count}, got #{got}" 
      end
    end

    it "should work with nil password" do
      got = StrongPasswordCharacterChangeCounter.new(nil).call

      expect(got).to eq(StrongPasswordCharacterChangeCounter::MIN_LEN)
    end
  end
end