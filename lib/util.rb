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

  def Util.insert_at_null_before(items, item, index)
    slot = items
      .length
      .times
      .reject { |i| items[i] }
      .select { |i| i < index }
      .max

    items[slot] = item if slot

    items
  end

  def Util.ord_eq?(val)
    -> (str) { str.ord == val }
  end
end
