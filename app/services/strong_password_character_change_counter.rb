# The main domain service which will calculate the character changes required
# to convert a password into a strong password.
class StrongPasswordCharacterChangeCounter
  MIN_LEN = 10
  MAX_LEN = 16

  def initialize(password)
    @password = password
    # Simple sanitisation
    if @password.nil?
      @password = ''
    end
  end

  # The main public interface method which return the character changes required
  # to convert a password into a strong password.
  # @returns Integer
  def call
    # The basic flow is very simple.
    # We have 3 constraints:
    # * Length between 10 and 16
    # * One character of each of these types - lowercase, uppercase, digits
    # * No repetition of 3 or more characters
    #
    # The tools we have at our disposal to achieve this change are addition,
    # removal and replacement of a character.
    # * Length change is straightforward, we either add or remove characters.
    # * To remove repetitions, the best strategy is replacement as with each
    #   replacement of the third character, we can completely remove any sequence
    #   in (N / 3) replacements.
    #   If we can't replace, we try to add as that is the second fastest method
    #   method and can remove sequences in (N-1) / 2 additions.
    #   Removals are the slowest approach and we basically have to remove all
    #   but the last 2 characters of a sequence so (N-2) removals.
    # * character types can be optimized by doing them along with addition or
    #   replacement. Removal is the only one where we need to separately handle
    #   missing character types.
    #
    # We can solve it by looking at the three cases
    #
    # Case 1 - Length between 10 and 16
    # This is the nicest.
    # We don't have to handle length change.
    # We can use replacement which is the optimum way to remove sequences.
    # During replacement we can choose from the missing character types and thus
    # we reduce the number of extra changes required.
    # This case is so nice that in the other two cases, we try to reduce them to
    # this case.
    #
    # Case 2 - Length < 10
    # Second best.
    # Sequence removal is slower than replacement, but at least we can choose
    # from missing character types when adding and thus optimize the solution.
    # We also try to use additions to remove sequences which save the most amount
    # of replacements. e.g. for sequences of length 3 and 4, we need 1 of either
    # addition or replacement, so we choose 1 addition to save 1 replacement.
    # 3 aaa -> 1 add, 1 replace -> 1 add == 1 replace, awesome
    # 4 aaaa -> 1 add, 1 replace -> 1 add == 1 replace, awesome
    # 5 aaaaa -> 2 add, 1 replace -> First add wasted, then 1 add == 1 replace
    # 6 aaaaaa -> 2 add, 2 replace -> 1 add == 1 replace, awesome
    # 7 aaaaaaa -> 3 add, 2 replace -> 1 add, 1 replace == 2 changes, awesome
    # 8 aaaaaaaa -> 3 add, 2 replace -> 1 add, 2 replace == 3 changes, awesome
    # 9 aaaaaaaaa -> 4 add, 3 replace -> 1 add, 2 replace == 3 changes, awesome
    # Here, if seq is 7,8 or 9, there can be no other sequence, so no sorting
    # if seq is 6, other can at most be 3, so any sequence is fine
    # if seq is 5, other can be 3 or 4, so we sort and work on 3 or 4 first
    # if seq is 4, other can be 3, 4, 5, again, we just sort and get to work
    # if seq is 3, other can be 3, 4, 5, 6, again, we just sort and get to work
    # So, all we need to do is simple sorting of repetitions.
    #
    # Case 3 - Length > 16
    # The worst case for one simple reason, we can't optimise missing character
    # types along with a removal, we'll have to do it separately via a replacement.
    # In removals the sequence is easier to see.
    # Whenever N(N being length of seq) is such that
    # N % 3 == 0, then if we do just one removal, it is equivalent to one
    # replacement. e.g. if N = 9, it would take 3 replacements(replace at 0 based
    # indices 2, 5, <6 or 7 or 8>). If we remove one and bring N down to 8, now
    # We need only 2 replacements. Thus, here 1 removal == 1 replacement.
    # We see the following relationship
    # * If N % 3 == 0, 1 removal == 1 replacement
    # * If N % 3 == 1, 2 removal == 1 replacement
    # * If N % 3 == 2, 3 removal == 1 replacement
    # Also, note that after these removals, they all end in the state where
    # remaining N % 3 == 2, thus they all then come down to 3 removals == 1 replacement.
    result = 0
    missing = calculate_missing_character_types
    repetitions = calculate_repetitions
    if @password.length < MIN_LEN
      additions = MIN_LEN - @password.length
      result += additions
      # remove repetitions using additions
      repetitions = remove_repetitions_using_addition(repetitions, additions)
      # reduce missing_character_types based on additions
      missing = [missing - additions, 0].max
      # fall through to the normal case with reduced number of repetitions and
      # reduced number of missing types
    elsif @password.length > MAX_LEN
      removals = @password.length - MAX_LEN
      result += removals
      # remove repetitions using removals
      repetitions = remove_repetitions_using_removal(repetitions, removals)
      # fall through to the normal case with reduced number of repetitions and
      # full amount of missing types
    end

    # This is the nice base case.
    # Here the password is in the length MIN_LEN and MAX_LEN
    # So, now we just use replacement to handle the remaining repetitions and
    # missing character types
    repetition_replacements = repetitions.sum { |rep| rep / 3 }

    # result is result + [missing_types, reduction_of_repetitions_using_replacement].max
    result + [missing, repetition_replacements].max
  end


  def remove_repetitions_using_removal(repetitions, removals)
    repetitions = repetitions.sort
    remaining_removals = removals
    i = 0
    new_repetitions = []

    # First pass, handle N % 3 == 0
    repetitions.each do |rep|
      if remaining_removals <= 0
        new_repetitions << rep
        next
      end
      
      if rep % 3 == 0
        remaining_removals -= 1
        new_repetitions << rep - 1
      elsif rep > 2
        new_repetitions << rep
      end
    end

    # Second pass, handle N % 3 == 1
    new_repetitions.each_with_index do |rep, i|
      break if remaining_removals <= 0
      
      if rep % 3 == 1
        used = [remaining_removals, 2].min
        remaining_removals -= used
        new_repetitions[i] = rep - used
      end
    end

    # Final pass, handle N % 3 == 2
    new_repetitions.each_with_index do |rep, i|
      break if remaining_removals <= 0
      
      used = [remaining_removals, rep - 2].min
      remaining_removals -= used
      new_repetitions[i] = rep - used
    end

    new_repetitions.select { |rep| rep > 2 }
  end


  def remove_repetitions_using_addition(repetitions, additions)
    repetitions = repetitions.sort
    remaining_additions = additions
    i = 0
    new_repetitions = []
    repetitions.each do |rep|
      if remaining_additions <= 0
        new_repetitions << rep
        next
      end
      additions_consumption = (rep - 1) / 2
      if remaining_additions >= additions_consumption
        rep = 0
      else
        rep -= remaining_additions * 2
      end

      remaining_additions -= additions_consumption
      i += 1
      if rep > 2
        new_repetitions << rep
      end
    end

    new_repetitions
  end


  def calculate_missing_character_types
    missing_character_types = 3
    
    missing_character_types -= 1 if /[a-z]/.match(@password)
    missing_character_types -= 1 if /[A-Z]/.match(@password)
    missing_character_types -= 1 if /\d/.match(@password)

    missing_character_types
  end


  def calculate_repetitions
    repetitions = {}
    prev = ''
    prev_prev = ''
    @password.each_char do |c|
      if c == prev && c == prev_prev
        if repetitions[c]
          repetitions[c] += 1
        else
          repetitions[c] = 3
        end
      end
      prev_prev = prev
      prev = c
    end

    return repetitions.map { |_c, count| count }
  end
end