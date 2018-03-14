local RoduxSelectors = {}

function RoduxSelectors.createSelector(...)
    local count = select("#", ...)
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
