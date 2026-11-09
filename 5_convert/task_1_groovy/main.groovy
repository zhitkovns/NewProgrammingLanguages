def escapeJson(String s) {
    if (s == null) return ""
    return s.replace("\\", "\\\\").replace("\"", "\\\"")
}

def m3uToJson(String content) {
    def playlist = []
    def currentDuration = 0
    def currentTitle = ""
    def currentArtist = ""
    def lineNum = 0

    content.eachLine { line ->
        lineNum++
        def trimmed = line.trim()
        if (trimmed.isEmpty() || trimmed == "#EXTM3U") return

        if (trimmed.startsWith("#EXTINF:")) {
            def matcher = trimmed =~ /#EXTINF:(-?\d+),(.+)/
            if (matcher.matches()) {
                try {
                    currentDuration = matcher[0][1] as Integer
                    def meta = matcher[0][2]
                    def parts = meta.split(" - ", 2)
                    if (parts.length == 2) {
                        currentArtist = parts[0].trim()
                        currentTitle = parts[1].trim()
                    } else {
                        currentArtist = "Unknown"
                        currentTitle = meta.trim()
                    }
                } catch (Exception e) {
                    System.err.println("line ${lineNum}: error parsing EXTINF - ${e.message}")
                }
            } else {
                System.err.println("line ${lineNum}: invalid EXTINF format")
            }
        } else if (!trimmed.startsWith("#")) {
            if (currentTitle.isEmpty()) {
                System.err.println("line ${lineNum}: file path without preceding metadata: ${trimmed}")
                return
            }
            playlist << [
                artist: currentArtist,
                title: currentTitle,
                duration: currentDuration,
                path: trimmed
            ]
            currentTitle = ""
            currentArtist = ""
            currentDuration = 0
        }
    }

    def json = new StringBuilder("[\n")
    playlist.eachWithIndex { track, i ->
        json.append("  {\n")
        json.append("    \"artist\": \"${escapeJson(track.artist)}\",\n")
        json.append("    \"title\": \"${escapeJson(track.title)}\",\n")
        json.append("    \"duration\": ${track.duration},\n")
        json.append("    \"path\": \"${escapeJson(track.path)}\"\n")
        json.append("  }")
        if (i < playlist.size() - 1) json.append(",")
        json.append("\n")
    }
    json.append("]")
    return json.toString()
}

def m3uContent = """#EXTM3U
#EXTINF:210,The Beatles - Come Together
01 - Come Together.mp3
#EXTINF:184,The Beatles - Something
02 - Something.mp3
#EXTINF:-1,Unknown Artist - Mystery Track
mystery.mp3"""

try {
    def resultJson = m3uToJson(m3uContent)
    println resultJson
} catch (Exception e) {
    System.err.println("fatal error: ${e.message}")
    System.exit(1)
}