module Util
  def Util.inc(state, key)
    state.merge(key => state[key] + 1)
  end

  def Util.dec(state, key)
    state.merge(key => state[key] - 1)
  end

  def Util.swap(arr, i1, i2)
    n = arr.dup
    n[i1], n[i2] = n[i2], n[i1]
    n
  end

  def Util.non_null_indexes(arr)
    0.upto(arr.length).select do |i|
      arr[i]
    end
  end

  def Util.null_before(items, index)
    items
      .length
      .times
      .reject { |i| items[i] }
      .select { |i| index.nil? || i < index }
      .max
  end

  def Util.set_at(items, item, index)
    items.length.times.map do |i|
      if i == index
        item
      else
        items[i]
      end
    end
  end

  def Util.ord_eq?(val)
    -> (str) { str && str.ord == val }
  end

  def Util.parse_dice_string(str)
    str
      .scan(/(\d+)(d\d+)|(d\d+)|(\d+)/)
      .map { |m| m.compact.reverse }
      .flat_map { |die, count = 1| [die] * count.to_i }
  end

  def Util.eval_die(die)
    if die =~ /d(\d+)/
      rand($1.to_i) + 1
    else
      die.to_i
    end
  end

  def Util.eval_dice(dice)
    results = dice.map { |die| [die, eval_die(die)] }

    results
      .map { |die, result| "(#{die} = #{result})" }
      .join(" + ")
      .concat(" = #{ results.sum { |_, r| r } }")
  end

  def Util.eval_dice_string(str)
    eval_dice(parse_dice_string(str))
  end
end
