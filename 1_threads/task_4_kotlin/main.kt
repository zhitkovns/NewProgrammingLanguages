import java.util.concurrent.locks.ReentrantLock
import kotlin.concurrent.thread
import kotlin.concurrent.withLock

fun main() {
    val text = """
        Kotlin is a modern programming language. It is concise and safe.
        Kotlin is interoperable with Java. Many developers use Kotlin for Android.
        Kotlin coroutines provide a way to write asynchronous code.
    """.trimIndent().lowercase()

    val words = text.split(Regex("\\W+")).filter { it.isNotEmpty() }
    val n = 2
    val numThreads = 4
    val chunkSize = words.size / numThreads

    val globalCounts = HashMap<String, Int>()
    val lock = ReentrantLock()

    val threads = (0 until numThreads).map { i ->
        thread {
            val start = i * chunkSize
            val end = if (i == numThreads - 1) words.size else (i + 1) * chunkSize
            val localCounts = HashMap<String, Int>()

            for (j in start until end) {
                if (j + n <= words.size) {
                    val ngram = (j until j + n).joinToString(" ") { words[it] }
                    localCounts[ngram] = localCounts.getOrDefault(ngram, 0) + 1
                }
            }

            lock.withLock {
                for ((ngram, count) in localCounts) {
                    globalCounts[ngram] = globalCounts.getOrDefault(ngram, 0) + count
                }
            }
        }
    }

    threads.forEach { it.join() }

    println("Top 5 bigrams:")
    globalCounts.entries
        .sortedByDescending { it.value }
        .take(5)
        .forEach { (ngram, count) ->
            println("$ngram: $count")
        }
}