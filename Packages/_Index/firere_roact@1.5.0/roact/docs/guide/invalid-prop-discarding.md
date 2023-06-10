!!! info "All of the following behaviour can be disabled entirely by setting `invalidPropDiscarding` to `false` in `Roact:setGlobalConfig()`. Functionality will return to being the same as Roblox's version, including any warnings or errors."

As mentioned in the last section, passing in an invalid prop into a host component does not error like in regular Roact. While this has its drawbacks — notably making it harder to spot invalid props intended to actually be properties and the inability to use `typeChecks` — this helps massively with overriding a component's default props without having to use sanitiser functions.

## Why?
Normally, to override default component props, you might do the following:

```lua
-- component code
function Button(props)
	local fullProps = {
		BackgroundColor3 = Color3.new(1, 0, 1),
		Size = UDim2.new(0, 100, 0, 50),
		Text = "Placeholder text",
		TextColor3 = Color3.new(1, 1, 1),
		TextStrokeColor3 = Color3.new(0, 0, 0),
	}

	for k, v in props do
		fullProps[k] = v
	end

	return Roact.createElement("TextButton", fullProps)
end
```

```lua
-- adding to/overriding default props
local buttonElement = Roact.createElement(Button, {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Size = UDim2.new(0, 600, 0, 400),
	Text = "Overriden text",
})
```

This can work at first, but issues arise when you want to use props other than the host components available properties:

```lua hl_lines="5"
function Button(props)
	local fullProps = {
		BackgroundColor3 = Color3.new(1, 0, 1),
		FontFace = Font.fromName("FredokaOne", props.FontStyle)
		Size = UDim2.new(0, 100, 0, 50),
		Text = "Placeholder text",
		TextColor3 = Color3.new(1, 1, 1),
		TextStrokeColor3 = Color3.new(0, 0, 0),
	}

	for k, v in props do
		fullProps[k] = v
	end

	return Roact.createElement("TextButton", fullProps)
end
```

This code looks fine at first, but during the `for` loop, it gets added to `fullProps`, thereby passing it as a prop into `TextButton`, which will error. You could override the `FontFace` prop itself, but if you ever want to change the font across the whole game (or at least every `Button`), then you have to go change every override of it instead of just in the component itself. The hassle of this stacks up the more complex your components are. The same applies to adding an exception for `FontStyle` in the `for` loop, but again the more invalid props there are, the larger the hassle of this is.

Another point at which this becomes a drag is when there are multiple versions of the same component, e.g. a secondary button. You could make a `BaseButton` component and extend your primary and secondary buttons from that, but should you also introduce active and inactive buttons, you'll have to make 4 separate components, which all have to incorporate the same merger `for` loop or any other shared logic across them, which isn't very D.R.Y.

Sometimes, invalid props may even have nothing to do with the actual style of the component itself, instead incorporating some other logic in them. In this example, it fires a `RemoteEvent`:

```lua hl_lines="10 11 12"
function Button(props)
	local fullProps = {
		BackgroundColor3 = Color3.new(1, 0, 1),
		Size = UDim2.new(0, 100, 0, 50),
		Text = "Placeholder text",
		TextColor3 = Color3.new(1, 1, 1),
		TextStrokeColor3 = Color3.new(0, 0, 0),
	}

	if props.IsASpecialButton then
		ReplicatedStorage.RemoteEvent:FireServer("Special button rendered!")
	end

	for k, v in props do
		fullProps[k] = v
	end

	return Roact.createElement("TextButton", fullProps)
end
```

In cases such as these, it's mostly a convenience for Roact to simply skip over invalid props when applying them to actual Roblox instances, rather than create impractical workarounds to both be able to add to and override default component props *and* incorporate extra logic based on props.