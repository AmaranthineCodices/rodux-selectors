return function()
    local Selector = require(script.Parent)

    describe("createSelector", function()
        it("should create selectors", function()
            local testSelector = Selector.createSelector(function()
            end)

            expect(testSelector).to.be.ok()
        end)
    end)
end