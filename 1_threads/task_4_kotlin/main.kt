import java.util.Random
import java.util.concurrent.locks.ReentrantLock
import kotlin.concurrent.thread
import kotlin.concurrent.withLock

class Account(val id: Int, var balance: Long) {
    val lock = ReentrantLock()
}

fun transfer(from: Account, to: Account, amount: Long) {
    // lock ordering by id to prevent deadlock
    val first = if (from.id < to.id) from else to
    val second = if (from.id < to.id) to else from

    first.lock.withLock {
        second.lock.withLock {
            if (from.balance >= amount) {
                from.balance -= amount
                to.balance += amount
            }
        }
    }
}

fun main() {
    val accounts = (1..5).map { Account(it, 1000L) }
    val initialTotal = accounts.sumOf { it.balance }

    val threads = (1..4).map { t ->
        thread {
            val rand = Random(t.toLong())
            repeat(1000) {
                val a = accounts[rand.nextInt(accounts.size)]
                val b = accounts[rand.nextInt(accounts.size)]
                if (a.id != b.id) {
                    transfer(a, b, (1 + rand.nextInt(50)).toLong())
                }
            }
        }
    }
    threads.forEach { it.join() }

    val finalTotal = accounts.sumOf { it.balance }
    println("initial total: $initialTotal")
    println("final total: $finalTotal")
    println("invariant preserved: ${initialTotal == finalTotal}")
    accounts.forEach { println("account ${it.id}: ${it.balance}") }
}