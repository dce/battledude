module Util
  def Util.inc(state, key, amount = 1)
    state.merge(key => state[key] + amount)
  end

  def Util.dec(state, key, amount = 1)
    state.merge(key => state[key] - amount)
  end

  def Util.swap(arr, i1, i2)
    n = arr.dup
    n[i1], n[i2] = n[i2], n[i1]
    n
  end

  def Util.non_null_indexes(arr)
    arr.length.times.select do |i|
      arr[i]
    end
  end

  def Util.null_indexes(arr)
    arr.length.times.reject do |i|
      arr[i]
    end
  end

  def Util.null_before(items, index)
    null_indexes(items)
      .select { |i| index.nil? || i < index }
      .max
  end

  def Util.null_after(items, index)
    null_indexes(items)
      .select { |i| index.nil? || i > index }
      .min
  end

  def Util.non_null_before(items, index)
    non_null_indexes(items)
      .select { |i| index.nil? || i < index }
      .max
  end

  def Util.non_null_after(items, index)
    non_null_indexes(items)
      .select { |i| index.nil? || i > index }
      .min
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
      .scan(/([\+\-]?)((\d+)(d\d+)|(d\d+)|(\d+))/)
      .map { |m| m.compact.reverse }
      .flat_map do |die, count = 1, _, sign|
        opp = sign == "-" ? :sub : :add
        [[die, opp]] * count.to_i
      end
  end

  def Util.eval_die(die)
    if die =~ /d(\d+)/
      rand($1.to_i) + 1
    else
      die.to_i
    end
  end

  def Util.eval_dice(dice)
    results = dice.map { |die, opp| [die, opp, eval_die(die)] }

    rolls = results.map do |result|
      die, opp, roll = result

      if result == results.first
        "(#{die} = #{roll})"
      else
        sign = opp == :add ? "+" : "-"
        " #{sign} (#{die} = #{roll})"
      end
    end

    sum = results.inject(0) do |total, (die, opp, roll)|
      opp == :add ? total + roll : total - roll
    end

    rolls.join.concat(" = #{ sum }")
  end

  def Util.eval_dice_string(str)
    eval_dice(parse_dice_string(str))
  end

  def Util.split_footer_string(str)
    line_length = Curses.cols - 4

    (0..(str.length)).step(line_length).map do |i|
      str[i...(i + line_length)].strip
    end
  end

  def Util.search_regex(str)
    /#{ str.chars.map { |c| "(#{c})" }.join("(.*?)") }/i
  end
end
