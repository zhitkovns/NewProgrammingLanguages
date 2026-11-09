struct Item
    key::Int32
    val::Float64
end

function create_test_files()
    files = [("sorted_a.bin", [1, 3, 5, 7]), ("sorted_b.bin", [2, 4, 6, 8])]
    for (name, keys) in files
        if !isfile(name)
            open(name, "w") do io
                for k in keys
                    write(io, Int32(k))
                    write(io, Float64(k) * 1.5)
                end
            end
        end
    end
end

function read_bin(filename::String)
    items = Item[]
    open(filename, "r") do io
        while !eof(io)
            k = read(io, Int32)
            v = read(io, Float64)
            push!(items, Item(k, v))
        end
    end
    return items
end

function merge_sorted(a::Vector{Item}, b::Vector{Item})
    res = Item[]
    i, j = 1, 1
    while i <= length(a) && j <= length(b)
        if a[i].key <= b[j].key
            push!(res, a[i])
            i += 1
        else
            push!(res, b[j])
            j += 1
        end
    end
    while i <= length(a)
        push!(res, a[i])
        i += 1
    end
    while j <= length(b)
        push!(res, b[j])
        j += 1
    end
    return res
end

function main()
    try
        create_test_files()
        a = read_bin("sorted_a.bin")
        b = read_bin("sorted_b.bin")
        merged = merge_sorted(a, b)
        
        open("merged.bin", "w") do io
            for item in merged
                write(io, item.key)
                write(io, item.val)
            end
        end
        
        println("Merged $(length(merged)) records into merged.bin")
        for item in merged
            println("Key: $(item.key), Value: $(item.val)")
        end
    catch e
        println(stderr, "error: ", e)
        exit(1)
    end
end

main()