<h1 align="center">Roact</h1>
<div align="center">
	<a href="https://firere.github.io/roact"><img src="https://img.shields.io/badge/docs-website-green.svg" alt="Documentation" />
</div>

<div align="center">
	An extension of [Roblox's Roact](https://github.com/Roblox/roact)
</div>

<div>&nbsp;</div>

## Installation

### Method 1: Filesystem
* Copy the `src` directory into your codebase
* Rename the folder to `Roact`
* Use a plugin like [Rojo](https://github.com/rojo-rbx/rojo) to sync the files into a place

### Method 2: Wally
* Add [Wally](https://wally.run) to your project
* Add `firere/roact` to your `dependencies` in `wally.toml`

## What's the difference?
* Whenever a prop is passed into a host component which is not a valid property of the target Roblox class, it does not error and simply skips over trying to apply it
* Whenever children are passed in both the `Roact.Children` key of `props` *and* in the `children` arguments of `createElement`, it will automatically merge them both
	* If 2 keys with the same name are found in both arguments, the `children` argument will replace the one in `props`; this can be configured

## [Documentation](https://firere.github.io/roact)
For a detailed guide and examples, check out the [documentation](https://firere.github.io/roact).

```lua
local LocalPlayer = game:GetService("Players").LocalPlayer

local Roact = require(Roact)

-- Create our virtual tree describing a full-screen text label.
local tree = Roact.createElement("ScreenGui", {
	[Roact.Children] = {
		Image = Roact.createElement("ImageLabel", {
			InvalidProp = "InvalidProp is not a valid property on the ImageLabel class" -- This does not produce an error.
		})
	}
}, {
	Label = Roact.createElement("TextLabel", { -- Both Image and Label will be children of tree.
		Text = "Hello, world!",
		Size = UDim2.new(1, 0, 1, 0),
	}),
})

-- Turn our virtual tree into real instances and put them in PlayerGui
Roact.mount(tree, LocalPlayer.PlayerGui, "HelloWorld")
```

## License
Roact is available under the Apache 2.0 license. See [LICENSE.txt](LICENSE.txt) for details.