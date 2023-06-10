!!! info "All of the following behaviour can be disabled entirely by setting `childMerging` to `false` in `Roact:setGlobalConfig()`. Functionality will return to being the same as Roblox's version, including any warnings or errors."

As mentioned in the [elements section](elements), Roblox's version of Roact would remove all children specified in the `props[Roact.Children]` argument of `createElement` and only apply the children specified in the `children` argument if both were specified, and would give you a warning:

```
The prop `Roact.Children` was defined but was overridden by the third parameter to createElement!
This can happen when a component passes props through to a child element but also uses the `children` argument:

	Roact.createElement("Frame", passedProps, {
		child = ...
	})

Instead, consider using a utility function to merge tables of children together:

	local children = mergeTables(passedProps[Roact.Children], {
		child = ...
	})

	local fullProps = mergeTables(passedProps, {
		[Roact.Children] = children
	})

	Roact.createElement("Frame", fullProps)
```

This version automatically does what the warning suggests you do, by merging `props[Roact.Children]` and the `children` argument. By default, the `children` argument takes precedence over `props[Roact.Children]` meaning that if there is a child with the same name then it will use the one in `children`. This can be changed in the global Roact configuration:

```lua
Roact:setGlobalConfig({
	propsPrecedence = true
})
```

!!! warning
	This behaviour does not apply to children whose key is of type `number` or those who do not have any key specified. These children are internally added via `table.insert`, meaning they will be both be added.
