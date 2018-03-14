local RoduxSelectors = {}

function RoduxSelectors.createSelector(...)
    local count = select("#", ...)

    -- Aggressively validate arguments
    if count < 1 then
        error("expected 1 or more arguments to createSelector, got 0", 2)
    end

    for i = 1, count do
        local arg = select(i, ...)

        if typeof(arg) ~= "function" then
            error(("bad argument #%d to createSelector: expected function, got %q"):format(
                i,
                typeof(arg)
            ))
        end
    end

    local dependencies = { ... }
    -- Remove the last value from the table. This is the selector being created.
    table.remove(dependencies, count)
    local selector = select(count, ...)

    local dependencyCache = {}
    local cachedResult = nil

    return function(state)
        local dirty = false
        local dependencyValues = {}

        for _, dependency in ipairs(dependencies) do
            local value = dependency(state)

            -- Rodux relies on immutable data, so a simple reference equality
            -- check will work perfectly here.
            if dependencyCache[dependency] ~= value then
                dirty = true
            end

            -- Update the cache always
            -- If the value is the same this will have no effect
            -- Otherwise it simplifies the code
            dependencyCache[dependency] = value
            table.insert(dependencyValues, value)
        end

        -- dirty will be set to true if and only if the values of *all* the
        -- dependent selectors have not changed.
        if dirty then
            local newValue = selector(unpack(dependencyValues))
            -- Cache the result so it isn't uselessly recomputed
            cachedResult = newValue
        end

        return cachedResult
    end
end

return RoduxSelectors
