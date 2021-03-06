return function()
    local Selector = require(script.Parent)

    describe("createSelector", function()
        it("should create selectors", function()
            local testSelector = Selector.createSelector({}, function()
            end)

            expect(testSelector).to.be.ok()
        end)

        it("should throw if passed no arguments", function()
            expect(function()
                Selector.createSelector()
            end).to.throw()
        end)

        it("should throw if passed invalid arguments", function()
            expect(function()
                Selector.createSelector({ 1 }, print)
            end).to.throw()

            expect(function()
                Selector.createSelector({ warn }, 2)
            end).to.throw()

            expect(function()
                Selector.createSelector(nil, print)
            end).to.throw()
        end)

        it("selectors should return a value", function()
            local testSource = function()
                return 1
            end

            local testSelector = Selector.createSelector({ testSource }, function(value1)
                return value1 * 2
            end)

            local value = testSelector()
            expect(value).to.equal(2)
        end)

        it("selectors should receive their arguments in order of declaration", function()
            local function a()
                return 1
            end

            local function b()
                return 2
            end

            local function c()
                return 3
            end

            local value1, value2, value3

            local selector = Selector.createSelector({ a, b, c }, function(v1, v2, v3)
                value1 = v1
                value2 = v2
                value3 = v3
            end)

            selector()
            expect(value1).to.equal(1)
            expect(value2).to.equal(2)
            expect(value3).to.equal(3)
        end)

        it("selectors should only be called when their dependencies change", function()
            local value = 0
            local dependencyCallCount = 0
            local selectorCallCount = 0

            local function dependency()
                dependencyCallCount = dependencyCallCount + 1
                return value
            end

            local selector = Selector.createSelector({ dependency }, function(dependentValue)
                selectorCallCount = selectorCallCount + 1
                return dependentValue + 1
            end)

            selector()
            expect(dependencyCallCount).to.equal(1)
            expect(selectorCallCount).to.equal(1)

            selector()
            expect(dependencyCallCount).to.equal(2)
            expect(selectorCallCount).to.equal(1)

            value = 2

            selector()
            expect(dependencyCallCount).to.equal(3)
            expect(selectorCallCount).to.equal(2)
        end)
    end)
end