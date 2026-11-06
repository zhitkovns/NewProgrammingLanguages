sealed trait Tree
case object Empty extends Tree
case class Node(value: Int, left: Tree, right: Tree) extends Tree

object Main {
  def insert(t: Tree, v: Int): Tree = t match {
    case Empty => Node(v, Empty, Empty)
    case Node(x, l, r) =>
      if (v < x) Node(x, insert(l, v), r)
      else if (v > x) Node(x, l, insert(r, v))
      else t
  }

  def contains(t: Tree, v: Int): Boolean = t match {
    case Empty => false
    case Node(x, l, r) =>
      if (v == x) true
      else if (v < x) contains(l, v)
      else contains(r, v)
  }

  def inOrder(t: Tree, acc: List[Int]): List[Int] = t match {
    case Empty => acc
    case Node(x, l, r) => inOrder(l, x :: inOrder(r, acc))
  }

  def height(t: Tree): Int = t match {
    case Empty => 0
    case Node(_, l, r) => 1 + math.max(height(l), height(r))
  }

  def main(args: Array[String]): Unit = {
    val values = List(50, 30, 70, 20, 40, 60, 80, 35)
    val tree = values.foldLeft[Tree](Empty)(insert)
    println("in-order: " + inOrder(tree, Nil).mkString(", "))
    println("height: " + height(tree))
    println("contains 40: " + contains(tree, 40))
    println("contains 45: " + contains(tree, 45))
  }
}