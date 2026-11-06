function process_file(input_path::String, output_path::String)
    if !isfile(input_path)
        error("file not found: $input_path")
    end

    numbers = Float64[]
    skipped = 0

    open(input_path, "r") do io
        for line in eachline(io)
            stripped = strip(line)
            if isempty(stripped)
                continue
            end
            parts = split(stripped, ',')
            if length(parts) < 2
                @warn "line skipped, not enough columns" line = stripped
                skipped += 1
                continue
            end
            val = tryparse(Float64, strip(parts[2]))
            if val === nothing
                @warn "line skipped, not a number" line = stripped
                skipped += 1
                continue
            end
            push!(numbers, val)
        end
    end

    if isempty(numbers)
        error("no valid numeric values in $input_path")
    end

    result = Dict(
        "count" => length(numbers),
        "sum" => sum(numbers),
        "mean" => sum(numbers) / length(numbers),
        "min" => minimum(numbers),
        "max" => maximum(numbers),
        "skipped" => skipped,
    )

    open(output_path, "w") do io
        for k in ["count", "sum", "mean", "min", "max", "skipped"]
            println(io, "$k: $(result[k])")
        end
    end

    println("processed $(length(numbers)) values, skipped $skipped lines")
    println("report written to $output_path")
end

function main()
    input = length(ARGS) >= 1 ? ARGS[1] : "data.csv"
    output = length(ARGS) >= 2 ? ARGS[2] : "stats.txt"
    try
        process_file(input, output)
    catch e
        println(stderr, "error: ", e)
        exit(1)
    end
end

main()