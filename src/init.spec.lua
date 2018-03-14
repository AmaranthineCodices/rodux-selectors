return function()
    local Selector = require(script.Parent)

    describe("createSelector", function()
        it("should create selectors", function()
            local testSelector = Selector.createSelector(function()
            end)

            expect(testSelector).to.be.ok()
        end)

        it("should throw if passed no arguments", function()
            expect(function()
                Selector.createSelector()
            end).to.throw()
        end)

        it("should throw if passed a non-function argument", function()
            expect(function()
                Selector.createSelector(print, 1, warn)
            end)
        end)
    end)
end