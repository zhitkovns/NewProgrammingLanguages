def parse_ini(path)
  sections = {}
  current = nil
  lineno = 0

  begin
    File.foreach(path) do |line|
      lineno += 1
      stripped = line.strip
      next if stripped.empty?
      next if stripped.start_with?(";") || stripped.start_with?("#")

      if stripped =~ /\A\[(.+)\]\z/
        current = Regexp.last_match(1).strip
        sections[current] ||= {}
      elsif stripped.include?("=")
        if current.nil?
          warn "line #{lineno}: key outside a section, skipped"
          next
        end
        key, value = stripped.split("=", 2)
        sections[current][key.strip] = value.strip
      else
        warn "line #{lineno}: unrecognized format, skipped"
      end
    end
  rescue SystemCallError => e
    warn "error reading file: #{e.message}"
    return nil
  end

  sections
end

def dump_ini(sections)
  out = []
  sections.each do |section, kv|
    out << "[#{section}]"
    kv.each { |k, v| out << "#{k}=#{v}" }
    out << ""
  end
  out.join("\n")
end

def main
  input = ARGV[0] || "config.ini"
  output = ARGV[1] || "output.txt"

  unless File.exist?(input)
    warn "error: file not found: #{input}"
    exit 1
  end

  begin
    sections = parse_ini(input)
    exit 1 if sections.nil?

    File.write(output, dump_ini(sections))

    total_keys = sections.values.sum(&:size)
    puts "parsed #{sections.size} sections, #{total_keys} keys"
    puts "written to #{output}"
  rescue StandardError => e
    warn "error: #{e.class}: #{e.message}"
    exit 1
  end
end

main