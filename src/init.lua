local RoduxSelectors = {}

function RoduxSelectors.createSelector(dependencies, selector)
    -- Aggressively validate arguments
    if typeof(dependencies) ~= "table" then
        error(("bad argument #1 to createSelector: expected function, got %q"):format(typeof(arg)), 2)
    else
        for index, dependency in ipairs(dependencies) do
            local type = typeof(dependency)

            if type ~= "function" then
                -- luacheck: ignore 6
                error(("bad argument #1 to createSelector: expected a table of functions\ndependency[%d] is not a function, is a %q"):format(
                    index,
                    type
                ), 2)
            end
        end
    end

    if typeof(selector) ~= "function" then
        error(("bad argument #2 to createSelector: expected function, got %q"):format(typeof(arg)), 2)
    end

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
