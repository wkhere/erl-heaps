erl-heaps
=========

Erlang implementation of a priority heap augmented with _O(log n)_
deletion by value & some other stuff very useful for A* pathfinding
algorithm.

All operations on a heap take _O(log n)_ time:

* `is_empty`
* `add`
* `take_min` (removes & returns element with min prority)
* `contains_value`
* `delete_by_value`

This is an extension of a classic priority heap which has only first
three operations. The A* algo uses deletion by value and it was
beneficial to have this operation be faster than linear.

Internally, the heap is just a joint of gb_tree holding priority heap
and a dict holding a reverse mapping from values to tree keys.


license
=======
This code is released under the BSD 2-Clause License.
