local function n_queens(n)
    local count = 0
    local first_solution = nil

    local function place(row, cols, d1, d2, current)
        if row > n then
            count = count + 1
            if not first_solution then
                local copy = {}
                for i = 1, n do copy[i] = current[i] end
                first_solution = copy
            end
            return
        end

        for col = 1, n do
            local a = row + col
            local b = row - col + n
            if not cols[col] and not d1[a] and not d2[b] then
                cols[col], d1[a], d2[b] = true, true, true
                current[row] = col
                place(row + 1, cols, d1, d2, current)
                cols[col], d1[a], d2[b] = false, false, false
            end
        end
    end

    place(1, {}, {}, {}, {})
    return count, first_solution
end

local n = 8
local count, solution = n_queens(n)
print("n = " .. n)
print("solutions: " .. count)
if solution then
    print("first solution: " .. table.concat(solution, " "))
end