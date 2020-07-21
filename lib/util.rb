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
end
