def escapeJson(String s) {
    return s.replace("\\", "\\\\").replace("\"", "\\\"")
}

def csvToJson(String csvContent) {
    def lines = csvContent.readLines().findAll { it.trim() }
    if (lines.isEmpty()) return "[]"

    def headers = lines[0].split(",").collect { it.trim() }
    def sb = new StringBuilder("[")
    boolean first = true

    for (int i = 1; i < lines.size(); i++) {
        def values = lines[i].split(",").collect { it.trim() }
        if (values.size() != headers.size()) {
            System.err.println("row ${i + 1}: expected ${headers.size()} columns, got ${values.size()}, skipped")
            continue
        }
        if (!first) sb.append(",")
        first = false
        sb.append("{")
        for (int j = 0; j < headers.size(); j++) {
            if (j > 0) sb.append(",")
            sb.append("\"${escapeJson(headers[j])}\":\"${escapeJson(values[j])}\"")
        }
        sb.append("}")
    }
    sb.append("]")
    return sb.toString()
}

def jsonToCsv(String json) {
    def content = json.trim()
    if (!content.startsWith("[") || !content.endsWith("]")) {
        throw new IllegalArgumentException("invalid json: no outer brackets")
    }
    content = content.substring(1, content.length() - 1).trim()
    if (content.isEmpty()) return ""

    def rows = []
    def matcher = content =~ /\{([^{}]*)\}/
    matcher.each { m ->
        def pairMatcher = m[1] =~ /"([^"]+)"\s*:\s*"([^"]*)"/
        def map = [:]
        pairMatcher.each { pm -> map[pm[1]] = pm[2] }
        rows << map
    }

    if (rows.isEmpty()) return ""

    def allKeys = new LinkedHashSet<String>()
    rows.each { r -> allKeys.addAll(r.keySet()) }
    def keys = allKeys.toList()

    def sb = new StringBuilder()
    sb.append(keys.join(",")).append("\n")
    rows.each { r ->
        sb.append(keys.collect { r[it] ?: "" }.join(",")).append("\n")
    }
    return sb.toString()
}

def csv = """name,age,city
Alice,30,New York
Bob,25,London"""

def json = csvToJson(csv)
println("json:")
println(json)

def back = jsonToCsv(json)
println("csv back:")
print(back)