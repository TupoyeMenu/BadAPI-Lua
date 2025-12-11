
---Usefull GUI components
Components = {}

---Shows a help marker that looks like this: (?), that when hovered displayes the text provided.
---@param text string
function Components.HelpMarker(text)
	ImGui.TextDisabled("(?)");
	if ImGui.IsItemHovered() then
		ImGui.BeginTooltip();
		ImGui.PushTextWrapPos(ImGui.GetFontSize() * 35);
		ImGui.Text(text);
		ImGui.PopTextWrapPos();
		ImGui.EndTooltip();
	end
end

---A button that will call a command when pressed.
---@param command string Command that will be called.
---@param label string The name of the button.
---@param callback fun()? Called when the button is pressed.
function Components.CommandButton(command, label, callback)
	local cmd = Command.GetTable()[command]
	if cmd == nil then
		ImGui.Text("INVALID COMMAND")
		return
	end

	if ImGui.Button(label) then
		Command.Call(Self.Id, command, true)
		if callback ~= nil then
			callback()
		end
	end
	local help_text = cmd:GetHelpText()
	if help_text ~= nil then
		ImGui.SameLine()
		Components.HelpMarker(help_text)
	end
end

---A checkbox that will toggle a convar when pressed.
---@param command string ConVar that will be toggled.
---@param label string The name of the checkbox.
---@param callback fun(new_state: boolean)? Called when the checkbox is pressed.
function Components.CommandCheckbox(command, label, callback)
	---@type ConVar
	local cmd = Command.GetTable()[command]
	if cmd == nil then
		ImGui.Text("INVALID COMMAND")
		return
	end

	local value, pressed = ImGui.Checkbox(label, cmd:GetBool())
	if pressed then
		cmd:SetBool(value)
		if callback ~= nil then
			callback(value)
		end
	end
	local help_text = cmd:GetHelpText()
	if help_text ~= nil then
		ImGui.SameLine()
		Components.HelpMarker(help_text)
	end
end
