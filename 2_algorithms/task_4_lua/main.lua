local function build_suffix_array(s)
    local n = #s
    if n == 0 then return {} end
    
    local sa = {}
    local rank = {}
    local tmp_rank = {}

    for i = 1, n do
        sa[i] = i
        rank[i] = string.byte(s, i)
    end

    local function sort_step(k)
        if k >= n then return end

        table.sort(sa, function(a, b)
            if rank[a] ~= rank[b] then return rank[a] < rank[b] end
            local ra = a + k <= n and rank[a + k] or -1
            local rb = b + k <= n and rank[b + k] or -1
            return ra < rb
        end)

        tmp_rank[sa[1]] = 1
        for i = 2, n do
            local prev, curr = sa[i-1], sa[i]
            local prev_rank2 = prev + k <= n and rank[prev + k] or -1
            local curr_rank2 = curr + k <= n and rank[curr + k] or -1
            if rank[prev] == rank[curr] and prev_rank2 == curr_rank2 then
                tmp_rank[curr] = tmp_rank[prev]
            else
                tmp_rank[curr] = tmp_rank[prev] + 1
            end
        end

        for i = 1, n do rank[i] = tmp_rank[i] end
        
        sort_step(k * 2)
    end

    sort_step(1)
    return sa
end

local s = "banana"
local sa = build_suffix_array(s)
io.write("Suffix array for '" .. s .. "': ")
for i = 1, #sa do
    io.write(sa[i] .. (i == #sa and "" or " "))
end
io.write("\n")