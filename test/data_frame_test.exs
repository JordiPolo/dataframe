defmodule DataFrameTest do
  use ExUnit.Case
  doctest DataFrame

  alias DataFrame.Frame

  def empty_frame do
    %Frame{values: [[]], index: [], columns: []}
  end

  def single_entry_frame do
    DataFrame.new([[00]], [:A])
  end

  # Creation

  describe "new/1" do
    test "Creates an empty frame from empty list of lists" do
      assert DataFrame.new([[]]) == empty_frame()
    end

    test "Creates a valid frame from a list of lists" do
      assert DataFrame.new([[1,2,3], [4,5,6]]) ==
        %Frame{values: [[1,2,3], [4,5,6]], index: [0,1], columns: [0,1,2]}
    end

    test "Creates Frame from a list of tuples" do
      assert DataFrame.new([{1,2,3}, {4,5,6}]) ==
        %Frame{values: [[1,2,3], [4,5,6]], index: [0,1], columns: [0,1,2]}
    end
  end

  describe "new/2" do
    test "Creates empty frame from empty inputs" do
      assert DataFrame.new([[]], []) == empty_frame()
    end

    test "Creates a Frame from regular inputs" do
      assert DataFrame.new([[0], [1]], [:A]) ==
        %Frame{values: [[0], [1]], index: [0, 1], columns: [:A]}
    end

    test "Exception when the dimensions do not match" do
      assert_raise ArgumentError, "Table dimension 1 does not match the row dimension 2", fn ->
        DataFrame.new([[0], [1]], [:A, :B])
      end
    end
  end

  describe "new/3" do
    test "Creates empty frame from empty inputs" do
      assert DataFrame.new([[]], [], []) == empty_frame()
    end

    test "Creates a Frame from regular inputs" do
      assert DataFrame.new([[0], [1]], [:A], [1,2]) ==
        %Frame{values: [[0], [1]], index: [1, 2], columns: [:A]}
    end

    test "Exception when the dimensions do not match" do
      assert_raise ArgumentError, "Table dimension 2 does not match the column dimension 1", fn ->
        DataFrame.new([[0], [1]], [:A], [1])
      end
    end
  end

  describe "parse/1" do
    test "Creates a DataFrame from parsed input" do
      input = "              A\n1             0\n2             1"
      assert DataFrame.parse(input) == %Frame{values: [[0], [1]], index: [1, 2], columns: ["A"]}
    end
  end

  # Selection

  describe "head/2" do
    test "empty Frame returns the empty Frame" do
      assert DataFrame.head(empty_frame(), 5) == empty_frame()
    end

    test "Frame that is shorter than the head size" do
      assert DataFrame.head(single_entry_frame(), 5) == single_entry_frame()
    end

    test "Two row Frame's head of one row is a Frame containing the first row" do
      assert DataFrame.head(DataFrame.new([[0], [1]], [:A]), 1) ==
        DataFrame.new([[0]], [:A])
    end
  end

  describe "tail/2" do
    test "empty Frame returns the empty Frame" do
      assert DataFrame.tail(empty_frame(), 5) == empty_frame()
    end

    test "Frame that is shorter than the tail size" do
      assert DataFrame.tail(single_entry_frame(), 5) == single_entry_frame()
    end

    test "Two row Frame's tail of one row is a Frame containing the last row" do
      assert DataFrame.tail(DataFrame.new([[0], [1]], [:A]), 1) ==
        DataFrame.new([[1]], [:A], [1])
    end
  end

  # Modification

  describe "transpose/1" do
    test "Transposing twice a dataframe gives the same grame" do
      assert DataFrame.transpose(DataFrame.transpose(single_entry_frame())) == single_entry_frame()
    end
    test "Transposing an empty Frame returns an empty Frame" do
      assert DataFrame.transpose(empty_frame()) == empty_frame()
    end
    test "Transposing a Frame with data returns a transposed frame" do
      frame = DataFrame.new([[2,3],[2,3]])
      assert DataFrame.transpose(frame) == DataFrame.new([[2,2],[3,3]])
    end
  end
end
