local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local TargetGuiProtected = (gethui and gethui()) or CoreGui:FindFirstChild("RobloxGui") or LocalPlayer:WaitForChild("PlayerGui")
local ConfigFolder = "OshiruConfig"
local ConfigFile = "OshiruConfig/settings.json"
local RuntimeSettings = {
	Optimized = false,
	Debug = false,
	SaveChoice = false
}
local function SaveConfiguration()
	if not isfolder(ConfigFolder) then
		makefolder(ConfigFolder)
	end
	writefile(ConfigFile, HttpService:JSONEncode(RuntimeSettings))
end
local function LoadConfiguration()
	if isfile(ConfigFile) then
		local ok, data = pcall(function()
			return HttpService:JSONDecode(readfile(ConfigFile))
		end)
		if ok and type(data) == "table" then
			return data
		end
	end
	return nil
end
local function ExecuteScript()
	local _OshiruStartTime = os.clock()
	getgenv().Optimized = RuntimeSettings.Optimized
	getgenv().Debug = RuntimeSettings.Debug
	local t1 = os.clock()
	local Inventory = require(ReplicatedStorage.Client.Systems.Inventory)
	local ClientRemotes = require(ReplicatedStorage.Client.ClientRemotes)
	local ZAP_RELIABLE = ReplicatedStorage:WaitForChild("ZAP"):WaitForChild("ZAP_RELIABLE")
	local ZAP_UNRELIABLE_0 = ReplicatedStorage:WaitForChild("ZAP"):WaitForChild("ZAP_UNRELIABLE_0")
	if getgenv().Debug then
		warn(string.format("[Oshiru Debug] Core Remotes & Utilities loaded in: %.4f seconds", os.clock() - t1))
	end
	local Config = {
		KillAura = { Enabled = false, Range = 9999, APS = 30, Targets = { "Monsters" } },
		ProximityTouch = { Enabled = false },
		Misc = { AutoHeal = false, AutoHealInterval = 1.5, AutoHealThreshold = 0.7 },
		Extra = { AutoOvercharge = false, AutoRevive = false },
		AutoPickup = { Enabled = false, Interval = 0.3, MaxDistance = math.huge, DeepScan = false, Filter = "All" },
		ItemESP = { Enabled = false, MaxDistance = 500 },
		Player = { WalkSpeedEnabled = false, WalkSpeedValue = 16, NoclipEnabled = false, JumpHeightEnabled = false, JumpHeightValue = 50 }
	}
	if getgenv()._OshiruMaid then
		getgenv()._OshiruMaid:Cleanup()
	end
	local Maid = {_tasks={}}
	Maid.Add = function(self, t)
		table.insert(self._tasks, t)
		return t
	end
	Maid.Cleanup = function(self)
		for _, t in ipairs(self._tasks) do
			if (typeof(t) == "RBXScriptConnection") then
				t:Disconnect()
			elseif (typeof(t) == "function") then
				t()
			elseif (typeof(t) == "Instance") then
				t:Destroy()
			end
		end
		table.clear(self._tasks)
	end
	getgenv()._OshiruMaid = Maid
	if getgenv()._OshiruESP then
		for _, d in pairs(getgenv()._OshiruESP) do
			pcall(function() d:Remove() end)
		end
	end
	getgenv()._OshiruESP = {}
	local _activeGunTable = nil
	local _cachedGunObjects = {}
	local _gcScanDue = true
	local t_son = os.clock()
	local function watchEquip(char)
		Maid:Add(char.ChildAdded:Connect(function(child)
			if child:IsA("Tool") then
				_gcScanDue = true
			end
		end))
	end
	if LocalPlayer.Character then
		watchEquip(LocalPlayer.Character)
	end
	Maid:Add(LocalPlayer.CharacterAdded:Connect(function(char)
		_gcScanDue = true
		watchEquip(char)
	end))
	if getgenv().Debug then
		warn(string.format("[Oshiru Debug] Loaded function son in: %.4f seconds", os.clock() - t_son))
	end
	local t2 = os.clock()
	local lib = loadstring(game:HttpGet("https://api.jnkie.com/api/v1/luascripts/public/5a48ca3ff3889b2947e1df1bb1c84d0eeca959d6d8037bf0cd35f8895073a18e/download"))()
	local window = lib:create_window({name="Oshiru", sub="Son"})
	local combat_tab = window:create_tab("Combat")
	local world_tab = window:create_tab("World")
	local player_tab = window:create_tab("Player")
	local misc_tab
	if not getgenv().Optimized then
		misc_tab = window:create_tab("Misc")
	end
	if getgenv().Debug then
		warn(string.format("[Oshiru Debug] UI Library Tabs generated in: %.4f seconds", os.clock() - t2))
	end
	local kill_aura_mod = combat_tab:create_module({name="Kill Aura"})
	local BringFilteredItems
	kill_aura_mod:create_checkbox({name="Enabled", default=false, flag="ka_enabled", callback=function(v) Config.KillAura.Enabled = v end})
	kill_aura_mod:create_slider({name="Attacks per Second", min=1, max=60, default=30, flag="ka_aps", callback=function(v) Config.KillAura.APS = v end})
	kill_aura_mod:create_slider({name="Range", min=10, max=9999, default=9999, flag="ka_range", callback=function(v) Config.KillAura.Range = v end})
	local _cachedPrompts = {}
	local proximity_mod = world_tab:create_module({name="Instant ProximityTouch"})
	proximity_mod:create_checkbox({name="Enabled", default=false, flag="pt_enabled", callback=function(v)
		Config.ProximityTouch.Enabled = v
		for prompt, origDuration in pairs(_cachedPrompts) do
			if (prompt and prompt.Parent) then
				prompt.HoldDuration = (v and 0) or origDuration
			end
		end
	end})
	local pickup_mod = world_tab:create_module({name="Auto Pickup"})
	pickup_mod:create_checkbox({name="Enabled", default=false, flag="ap_enabled", callback=function(v) Config.AutoPickup.Enabled = v end})
	pickup_mod:create_slider({name="Scan Interval", min=1, max=30, default=3, flag="ap_interval", callback=function(v) Config.AutoPickup.Interval = v * 0.1 end})
	pickup_mod:create_dropdown({name="Max Distance", options={"Infinite","500 studs","200 studs","100 studs"}, default="Infinite", flag="ap_dist", callback=function(v)
		local map = {Infinite=math.huge, ["500 studs"]=500, ["200 studs"]=200, ["100 studs"]=100}
		Config.AutoPickup.MaxDistance = map[v] or math.huge
	end})
	pickup_mod:create_dropdown({name="Filter", options={"All","Zombies","Food","Materials"}, default="All", flag="ap_filter", callback=function(v) Config.AutoPickup.Filter = v end})
	pickup_mod:create_checkbox({name="Deep Scan", default=false, flag="ap_deep", callback=function(v) Config.AutoPickup.DeepScan = v end})
	pickup_mod:create_button({name = "Bring Items", callback = function()
		if BringFilteredItems then
			task.spawn(BringFilteredItems)
		end
	end})
	local esp_mod = world_tab:create_module({name="Item ESP"})
	esp_mod:create_checkbox({name="Enabled", default=false, flag="esp_enabled", callback=function(v)
		Config.ItemESP.Enabled = v
		if not v then
			for _, d in pairs(getgenv()._OshiruESP) do
				pcall(function() d:Remove() end)
			end
			table.clear(getgenv()._OshiruESP)
		end
	end})
	esp_mod:create_slider({name="Max Distance", min=50, max=2000, default=500, flag="esp_dist", callback=function(v) Config.ItemESP.MaxDistance = v end})
	if not getgenv().Optimized and misc_tab then
		local healing_mod = misc_tab:create_module({name="Healing"})
		healing_mod:create_checkbox({name="Auto Heal", default=false, flag="ah_enabled", callback=function(v) Config.Misc.AutoHeal = v end})
		healing_mod:create_slider({name="HP Threshold", min=10, max=99, default=70, flag="ah_threshold", callback=function(v) Config.Misc.AutoHealThreshold = v / 100 end})
		local extra_mod = misc_tab:create_module({name="Extra"})
		extra_mod:create_checkbox({name="Auto Overcharge", default=false, flag="ex_overcharge", callback=function(v) Config.Extra.AutoOvercharge = v end})
		extra_mod:create_checkbox({name="Auto Free Revive", default=false, flag="ex_revive", callback=function(v) Config.Extra.AutoRevive = v end})
	end
	local movement_mod = player_tab:create_module({name="Movement Configuration"})
	movement_mod:create_checkbox({name="Loop WalkSpeed", default=false, flag="pl_ws_toggle", callback=function(v) Config.Player.WalkSpeedEnabled = v end})
	movement_mod:create_slider({name="WalkSpeed Value", min=16, max=300, default=16, flag="pl_ws_val", callback=function(v) Config.Player.WalkSpeedValue = v end})
	movement_mod:create_checkbox({name="Loop Jump Height", default=false, flag="pl_jh_toggle", callback=function(v) Config.Player.JumpHeightEnabled = v end})
	movement_mod:create_slider({name="Jump Height Value", min=50, max=300, default=50, flag="pl_jh_val", callback=function(v) Config.Player.JumpHeightValue = v end})
	local player_collision_mod = player_tab:create_module({name="Noclip"})
	player_collision_mod:create_checkbox({name="Enabled", default=false, flag="pl_noclip_toggle", callback=function(v) Config.Player.NoclipEnabled = v end})
	local function getRoot()
		local c = LocalPlayer.Character
		return c and c:FindFirstChild("HumanoidRootPart")
	end
	local UUID_PATTERN = "^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$"
	local function buildPickupBuffer(uuid)
		local len = #uuid
		return buffer.fromstring("\026" .. string.char(len % 256) .. string.char(math.floor(len / 256)) .. uuid)
	end
	local function firePickupRemotes(uuid)
		ZAP_RELIABLE:FireServer(buildPickupBuffer(uuid), {})
		ZAP_RELIABLE:FireServer(buffer.fromstring("\024\001\001"), {})
	end
	local PICKUP_FILTER_PATTERNS = {
		Zombies = {"zombie","rat","banana","carrot","strawberry","eggplant","orange","mushroom","fire","golden","sewer","radioactive","obese","corpse","carcass","body","thief"},
		Food = {"meat","yeast","cheese","egg","chicken","carrot","strawberry","banana","bread","flour","sugar","salt","milk","butter","dough","batter","ingredient","food","pie","explosive meat","carrots","blueberries","grapes","onions","rat meat","radioactive rat meat","radioactive egg"},
		Materials = {"plank","wood","metal","bar","bandage","nail","*****","bolt","wire","pipe","board","iron","steel","lumber","material","repair"}
	}
	local function itemMatchesFilter(name)
		local filter = Config.AutoPickup.Filter
		if (filter == "All") then return true end
		local lname = name:lower()
		local patterns = PICKUP_FILTER_PATTERNS[filter]
		if not patterns then return true end
		for _, kw in ipairs(patterns) do
			if lname:find(kw, 1, true) then return true end
		end
		return false
	end
	local _cachedInterFolder = nil
	local Skip = { Projectiles = true, SummonedMonsters = true, Monsters = true, Civilians = true, Interactables = true }
	local t_sonion = os.clock()
	BringFilteredItems = function()
		local root = getRoot()
		if not root then return end
		local targetCFrame = root.CFrame
		local interFolder = Workspace:FindFirstChild("Interactables")
		if interFolder then
			for _, model in ipairs(interFolder:GetChildren()) do
				if not model:IsA("Model") then continue end
				if model:FindFirstChild("ProductPriceTag") then continue end
				local uuid = model:GetAttribute("ObjectUUID")
				if type(uuid) == "string" and uuid:match(UUID_PATTERN) then
					if itemMatchesFilter(model.Name) then
						pcall(function() model:PivotTo(targetCFrame) end)
					end
				end
			end
		end
		local charSkip = {}
		for _, p in ipairs(Players:GetPlayers()) do
			if p.Character then charSkip[p.Character] = true end
		end
		local function shouldSkip(inst)
			local parent = inst.Parent
			if parent then
				if Skip[parent.Name] or charSkip[parent] then return true end
				local gp = parent.Parent
				if gp and (Skip[gp.Name] or charSkip[gp]) then return true end
			end
			return false
		end
		local function tryBringLegacy(inst)
			if not inst:IsA("BasePart") and not inst:IsA("Model") then return end
			if inst:FindFirstChild("ProductPriceTag") then return end
			if shouldSkip(inst) or not itemMatchesFilter(inst.Name) then return end
			local uuid = inst:GetAttribute("UUID") or inst:GetAttribute("ObjectId") or inst:GetAttribute("ItemId") or inst:GetAttribute("slotObjectId")
			if not uuid then
				local sv = inst:FindFirstChild("UUID") or inst:FindFirstChild("ItemId") or inst:FindFirstChild("ObjectId")
				if sv and sv:IsA("StringValue") then uuid = sv.Value end
			end
			if type(uuid) == "string" and uuid ~= "" then
				pcall(function()
					if inst:IsA("Model") then
						inst:PivotTo(targetCFrame)
					elseif inst:IsA("BasePart") then
						inst.CFrame = targetCFrame
					end
				end)
			end
		end
		for _, child in ipairs(Workspace:GetChildren()) do
			if Skip[child.Name] then continue end
			tryBringLegacy(child)
			if child:IsA("Folder") or child:IsA("Model") then
				for _, gc in ipairs(child:GetChildren()) do
					tryBringLegacy(gc)
					if Config.AutoPickup.DeepScan and (gc:IsA("Folder") or gc:IsA("Model")) then
						for _, ggc in ipairs(gc:GetChildren()) do
							tryBringLegacy(ggc)
						end
					end
				end
			end
		end
	end
	if getgenv().Debug then
		warn(string.format("[Oshiru Debug] Loaded sonion in: %.4f seconds", os.clock() - t_sonion))
	end
	local t_tuna = os.clock()
	local function scanForPickups()
		local interactable, legacy = {}, {}
		local root = getRoot()
		local maxDist = Config.AutoPickup.MaxDistance
		local function inRange(pos)
			return not root or (maxDist == math.huge) or ((pos - root.Position).Magnitude <= maxDist)
		end
		local function posOf(inst)
			if inst:IsA("Model") then
				return (inst.PrimaryPart and inst.PrimaryPart.Position) or (inst:FindFirstChildOfClass("BasePart") and inst:FindFirstChildOfClass("BasePart").Position)
			elseif inst:IsA("BasePart") then
				return inst.Position
			end
			return nil
		end
		if not (_cachedInterFolder and _cachedInterFolder.Parent) then
			_cachedInterFolder = Workspace:FindFirstChild("Interactables")
		end
		if _cachedInterFolder then
			for _, model in ipairs(_cachedInterFolder:GetChildren()) do
				if not model:IsA("Model") then continue end
				if model:FindFirstChild("ProductPriceTag") then continue end
				local uuid = model:GetAttribute("ObjectUUID")
				if ((type(uuid) ~= "string") or not uuid:match(UUID_PATTERN)) then continue end
				if not itemMatchesFilter(model.Name) then continue end
				local pos = posOf(model)
				if (pos and not inRange(pos)) then continue end
				table.insert(interactable, {uuid=uuid, model=model, name=model.Name})
			end
		end
		local charSkip = {}
		for _, p in ipairs(Players:GetPlayers()) do
			if p.Character then charSkip[p.Character] = true end
		end
		local function shouldSkip(inst)
			local parent = inst.Parent
			if parent then
				if (Skip[parent.Name] or charSkip[parent]) then return true end
				local gp = parent.Parent
				if (gp and (Skip[gp.Name] or charSkip[gp])) then return true end
			end
			return false
		end
		local function tryLegacy(inst)
			if (not inst:IsA("BasePart") and not inst:IsA("Model")) then return end
			if inst:FindFirstChild("ProductPriceTag") then return end
			if (shouldSkip(inst) or not itemMatchesFilter(inst.Name)) then return end
			local uuid = inst:GetAttribute("UUID") or inst:GetAttribute("ObjectId") or inst:GetAttribute("ItemId") or inst:GetAttribute("slotObjectId")
			if not uuid then
				local sv = inst:FindFirstChild("UUID") or inst:FindFirstChild("ItemId") or inst:FindFirstChild("ObjectId")
				if (sv and sv:IsA("StringValue")) then uuid = sv.Value end
			end
			if ((type(uuid) ~= "string") or (uuid == "")) then return end
			local pos = posOf(inst)
			if (pos and not inRange(pos)) then return end
			table.insert(legacy, {uuid=uuid, inst=inst, name=inst.Name})
		end
		for _, child in ipairs(Workspace:GetChildren()) do
			if Skip[child.Name] then continue end
			tryLegacy(child)
			if (child:IsA("Folder") or child:IsA("Model")) then
				for _, gc in ipairs(child:GetChildren()) do
					tryLegacy(gc)
					if (Config.AutoPickup.DeepScan and (gc:IsA("Folder") or gc:IsA("Model"))) then
						for _, ggc in ipairs(gc:GetChildren()) do
							tryLegacy(ggc)
						end
					end
				end
			end
		end
		return interactable, legacy
	end
	if getgenv().Debug then
		warn(string.format("[Oshiru Debug] Loaded sonmarino tuna in: %.4f seconds", os.clock() - t_tuna))
	end
	local t_esp = os.clock()
	local function updateESP(interactable, legacy)
		local camera = Workspace.CurrentCamera
		local root = getRoot()
		if not root then
			for _, d in pairs(getgenv()._OshiruESP) do d.Visible = false end
			return
		end
		local activeUUIDs = {}
		local function processList(list)
			for _, item in ipairs(list) do activeUUIDs[item.uuid] = true end
		end
		processList(interactable)
		processList(legacy)
		for uuid, d in pairs(getgenv()._OshiruESP) do
			if not activeUUIDs[uuid] then
				pcall(function() d:Remove() end)
				getgenv()._OshiruESP[uuid] = nil
			else
				d.Visible = false
			end
		end
		local maxDist = Config.ItemESP.MaxDistance
		local function renderItem(uuid, inst, name)
			local pos = (inst:IsA("Model") and ((inst.PrimaryPart and inst.PrimaryPart.Position) or (inst:FindFirstChildOfClass("BasePart") and inst:FindFirstChildOfClass("BasePart").Position))) or (inst:IsA("BasePart") and inst.Position) or nil
			if not pos then return end
			local dist = (pos - root.Position).Magnitude
			local d = getgenv()._OshiruESP[uuid]
			if (dist > maxDist) then
				if d then d.Visible = false end
				return
			end
			local sp, onScreen = camera:WorldToViewportPoint(pos)
			if not onScreen then
				if d then d.Visible = false end
				return
			end
			if not d then
				d = Drawing.new("Text")
				d.Size = 13
				d.Center = true
				d.Outline = true
				d.OutlineColor = Color3.new(0, 0, 0)
				d.Font = Drawing.Fonts.UI
				getgenv()._OshiruESP[uuid] = d
			end
			d.Color = Color3.new(1 - math.clamp(dist / maxDist, 0, 1), 1, 0)
			d.Text = string.format("[%s] %.0fm", name, dist)
			d.Position = Vector2.new(sp.X, sp.Y - 10)
			d.Visible = true
		end
		for _, item in ipairs(interactable) do renderItem(item.uuid, item.model, item.name) end
		for _, item in ipairs(legacy) do renderItem(item.uuid, item.inst, item.name) end
	end
	if getgenv().Debug then
		warn(string.format("[Oshiru Debug] Loaded son of a gun in: %.4f seconds", os.clock() - t_esp))
	end
	local function addPrompt(desc)
		if desc:IsA("ProximityPrompt") then
			if not _cachedPrompts[desc] then
				_cachedPrompts[desc] = desc.HoldDuration
			end
			if Config.ProximityTouch.Enabled then
				desc.HoldDuration = 0
			end
		end
	end
	task.spawn(function()
		local descendants = Workspace:GetDescendants()
		for i, desc in ipairs(descendants) do
			addPrompt(desc)
			if (i % 200 == 0) then task.wait() end
		end
	end)
	Maid:Add(Workspace.DescendantAdded:Connect(addPrompt))
	Maid:Add(Workspace.DescendantRemoving:Connect(function(desc)
		if _cachedPrompts[desc] then _cachedPrompts[desc] = nil end
	end))
	local function triggerPrompt(prompt)
		if (typeof(rawget(_G, "fireproximityprompt")) == "function") then
			pcall(rawget(_G, "fireproximityprompt"), prompt)
		else
			pcall(function()
				local prev = prompt.HoldDuration
				prompt.HoldDuration = 0
				task.delay(0.2, function()
					pcall(function() prompt.HoldDuration = prev end)
				end)
			end)
		end
	end
	Maid:Add(UserInputService.InputBegan:Connect(function(input, gpe)
		if (gpe or not Config.ProximityTouch.Enabled) then return end
		if ((input.UserInputType ~= Enum.UserInputType.MouseButton1) and (input.KeyCode ~= Enum.KeyCode.E)) then return end
		local root = getRoot()
		if not root then return end
		local nearest, nearestDist = nil, math.huge
		for prompt in pairs(_cachedPrompts) do
			if not (prompt.Parent and prompt.Enabled) then continue end
			local p = prompt.Parent
			local pos = (p:IsA("BasePart") and p.Position) or (p:IsA("Model") and ((p.PrimaryPart and p.PrimaryPart.Position) or (p:FindFirstChildOfClass("BasePart") and p:FindFirstChildOfClass("BasePart").Position))) or nil
			if not pos then continue end
			local dist = (pos - root.Position).Magnitude
			if ((dist <= (prompt.MaxActivationDistance + 1)) and (dist < nearestDist)) then
				nearest = prompt
				nearestDist = dist
			end
		end
		if nearest then triggerPrompt(nearest) end
	end))
	local t3 = os.clock()
	local function StartObjectScanner()
		Maid:Add(RunService.Heartbeat:Connect(function()
			if _gcScanDue then
				_gcScanDue = false
				table.clear(_cachedGunObjects)
				for _, obj in ipairs(getgc(true)) do
					if ((type(obj) == "table") and rawget(obj, "itemName") and rawget(obj, "activeSlot") and (rawget(obj, "reloading") ~= nil) and rawget(obj, "fireRate") and rawget(obj, "bulletRange")) then
						table.insert(_cachedGunObjects, obj)
					end
				end
			end
			_activeGunTable = nil
			local char = LocalPlayer.Character
			local tool = char and char:FindFirstChildOfClass("Tool")
			if tool then
				for _, obj in ipairs(_cachedGunObjects) do
					if (rawget(obj, "itemName") == tool.Name) then
						_activeGunTable = obj
						break
					end
				end
			end
		end))
	end
	local function findMeleeSlot()
		local ok, state = pcall(Inventory.getState)
		if (not ok or not state) then return nil end
		local gunNames = {}
		for _, obj in ipairs(_cachedGunObjects) do
			local n = rawget(obj, "itemName")
			if n then gunNames[n] = true end
		end
		for slotIdx, slotData in pairs(state) do
			if (slotData.storedObjects and (#slotData.storedObjects > 0)) then
				local n = slotData.storedObjects[1].objectName or slotData.storedObjects[1].itemName
				if (n and not gunNames[n]) then return slotIdx end
			end
		end
		return nil
	end
	local function StartKillAura()
		local nextAttack = 0
		Maid:Add(RunService.Heartbeat:Connect(function()
			if (not Config.KillAura.Enabled or (os.clock() < nextAttack)) then return end
			nextAttack = os.clock() + (1 / Config.KillAura.APS)
			local root = getRoot()
			if not root then return end
			local inRange = {}
			for _, folderName in ipairs(Config.KillAura.Targets) do
				local folder = Workspace:FindFirstChild(folderName)
				if not folder then continue end
				for _, model in ipairs(folder:GetChildren()) do
					if not model:IsA("Model") then continue end
					local hrp = model:FindFirstChild("HumanoidRootPart")
					if (not hrp or ((hrp.Position - root.Position).Magnitude > Config.KillAura.Range)) then continue end
					local hum = model:FindFirstChild("Humanoid")
					if (hum and (hum.Health > 0)) then table.insert(inRange, model) end
				end
			end
			if (#inRange == 0) then return end
			local attackSlot
			if _activeGunTable then
				attackSlot = findMeleeSlot()
				if not attackSlot then return end
			else
				local ok, s = pcall(Inventory.getActiveSlot)
				attackSlot = (ok and (type(s) == "number") and s) or 1
			end
			ClientRemotes.meleeAttack.fire({monsters=inRange, civilians={}, activeSlot=attackSlot})
		end))
	end
	local function StartMiscLoop()
		local lastHeal, lastOvercharge, lastRevive = 0, 0, 0
		Maid:Add(RunService.Heartbeat:Connect(function()
			local now = os.clock()
			if (Config.Misc.AutoHeal and ((now - lastHeal) >= Config.Misc.AutoHealInterval)) then
				local char = LocalPlayer.Character
				local hum = char and char:FindFirstChild("Humanoid")
				if (hum and (hum.Health < (hum.MaxHealth * Config.Misc.AutoHealThreshold))) then
					lastHeal = now
					local ok, slot = pcall(Inventory.getActiveSlot)
					ClientRemotes.useHealingItem.fire({targetPlayer=nil, activeSlot=((ok and (type(slot) == "number") and slot) or 1)})
				end
			end
			if (Config.Extra.AutoOvercharge and ((now - lastOvercharge) >= 0.1)) then
				lastOvercharge = now
				pcall(ClientRemotes.activateOvercharge.fire)
			end
			if (Config.Extra.AutoRevive and ((now - lastRevive) >= 1)) then
				lastRevive = now
				pcall(ClientRemotes.useFreeRevive.fire)
			end
		end))
	end
	local function StartWorldLoop()
		local pickupSent = {}
		local RESEND_COOLDOWN = 5
		local lastScanTick, lastESPTick = 0, 0
		local _cachedInter, _cachedLegacy = {}, {}
		local _pendingInter, _pendingLegacy = {}, {}
		local _pendingReady, _scanRunning = false, false
		Maid:Add(RunService.Heartbeat:Connect(function()
			local now = os.clock()
			if _pendingReady then
				_cachedInter, _cachedLegacy, _pendingReady = _pendingInter, _pendingLegacy, false
			end
			if ((Config.AutoPickup.Enabled or Config.ItemESP.Enabled) and not _scanRunning and ((now - lastScanTick) >= Config.AutoPickup.Interval)) then
				lastScanTick, _scanRunning = now, true
				task.spawn(function()
					local i, l = scanForPickups()
					_pendingInter, _pendingLegacy, _pendingReady, _scanRunning = i, l, true, false
				end)
			end
			if Config.AutoPickup.Enabled then
				for uuid, sentAt in pairs(pickupSent) do
					if ((now - sentAt) > RESEND_COOLDOWN) then pickupSent[uuid] = nil end
				end
				for _, item in ipairs(_cachedInter) do
					if not pickupSent[item.uuid] then
						pickupSent[item.uuid] = now
						pcall(firePickupRemotes, item.uuid)
					end
				end
				for _, item in ipairs(_cachedLegacy) do
					if not pickupSent[item.uuid] then
						pickupSent[item.uuid] = now
						pcall(ClientRemotes.pickupObject.fire, item.uuid)
					end
				end
			end
			if (Config.ItemESP.Enabled and ((now - lastESPTick) >= 0.2)) then
				lastESPTick = now
				updateESP(_cachedInter, _cachedLegacy)
			end
		end))
	end
	local function StartPlayerLoop()
		local wasWalkSpeedEnabled = false
		local wasJumpHeightEnabled = false
		local defaultWalkSpeed = 16
		local defaultJumpPower = 50
		local defaultJumpHeight = 7.2
		Maid:Add(LocalPlayer.CharacterAdded:Connect(function()
			wasWalkSpeedEnabled = false
			wasJumpHeightEnabled = false
		end))
		Maid:Add(RunService.Stepped:Connect(function()
			local char = LocalPlayer.Character
			if not char then return end
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum then
				if Config.Player.WalkSpeedEnabled then
					if not wasWalkSpeedEnabled then
						defaultWalkSpeed = hum.WalkSpeed
						wasWalkSpeedEnabled = true
					end
					hum.WalkSpeed = Config.Player.WalkSpeedValue
				elseif wasWalkSpeedEnabled then
					hum.WalkSpeed = defaultWalkSpeed
					wasWalkSpeedEnabled = false
				end
				if Config.Player.JumpHeightEnabled then
					if not wasJumpHeightEnabled then
						defaultJumpPower = hum.JumpPower
						defaultJumpHeight = hum.JumpHeight
						wasJumpHeightEnabled = true
					end
					if hum.UseJumpPower then
						hum.JumpPower = Config.Player.JumpHeightValue
					else
						hum.JumpHeight = Config.Player.JumpHeightValue
					end
				elseif wasJumpHeightEnabled then
					hum.JumpPower = defaultJumpPower
					hum.JumpHeight = defaultJumpHeight
					wasJumpHeightEnabled = false
				end
			end
			if Config.Player.NoclipEnabled then
				for _, player in ipairs(Players:GetPlayers()) do
					local character = player.Character
					if character then
						for _, part in ipairs(character:GetDescendants()) do
							if part:IsA("BasePart") then part.CanCollide = false end
						end
					end
				end
			end
		end))
	end
	local t_sonson = os.clock()
	StartObjectScanner()
	if getgenv().Debug then
		warn(string.format("[Oshiru Debug] Loaded sonson in: %.4f seconds", os.clock() - t_sonson))
	end
	local t_sonic = os.clock()
	StartKillAura()
	if getgenv().Debug then
		warn(string.format("[Oshiru Debug] Loaded sonicspeed in: %.4f seconds", os.clock() - t_sonic))
	end
	if not getgenv().Optimized then
		local t_sunset = os.clock()
		StartMiscLoop()
		if getgenv().Debug then
			warn(string.format("[Oshiru Debug] Loaded sunset son in: %.4f seconds", os.clock() - t_sunset))
		end
	end
	local t_grand = os.clock()
	StartWorldLoop()
	if getgenv().Debug then
		warn(string.format("[Oshiru Debug] Loaded grandson in: %.4f seconds", os.clock() - t_grand))
	end
	local t_season = os.clock()
	StartPlayerLoop()
	if getgenv().Debug then
		warn(string.format("[Oshiru Debug] Loaded seasoned son in: %.4f seconds", os.clock() - t_season))
	end
	if getgenv().Debug then
		warn(string.format("[Oshiru Debug] Core Runtime Loops started in: %.4f seconds", os.clock() - t3))
	end
	print("[Oshiru] Loaded successfully.")
	warn(string.format("Loaded in: %.4f seconds", os.clock() - _OshiruStartTime))
end
local function LaunchLoadingUI()
	local LoadingGui = Instance.new("ScreenGui")
	LoadingGui.Name = "OshiruLoader"
	LoadingGui.ResetOnSpawn = false
	LoadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	LoadingGui.Parent = TargetGuiProtected
	local MainFrame = Instance.new("CanvasGroup")
	MainFrame.Name = "MainFrame"
	MainFrame.Size = UDim2.new(0, 380, 0, 150)
	MainFrame.Position = UDim2.new(0.5, -190, 0.5, -65)
	MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
	MainFrame.BackgroundTransparency = 0.25
	MainFrame.BorderSizePixel = 0
	MainFrame.GroupTransparency = 1
	MainFrame.Parent = LoadingGui
	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(0, 16)
	UICorner.Parent = MainFrame
	local UIStroke = Instance.new("UIStroke")
	UIStroke.Thickness = 1
	UIStroke.Color = Color3.fromRGB(50, 50, 70)
	UIStroke.Transparency = 0.4
	UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	UIStroke.Parent = MainFrame
	local Title = Instance.new("TextLabel")
	Title.Size = UDim2.new(1, 0, 0, 50)
	Title.BackgroundTransparency = 1
	Title.Text = "OSHIRU SYSTEM INTERFACE"
	Title.TextColor3 = Color3.fromRGB(255, 255, 255)
	Title.Font = Enum.Font.GothamBold
	Title.TextSize = 14
	Title.Parent = MainFrame
	local Status = Instance.new("TextLabel")
	Status.Size = UDim2.new(1, -40, 0, 20)
	Status.Position = UDim2.new(0, 20, 0.45, 0)
	Status.BackgroundTransparency = 1
	Status.Text = "Initializing pipelines"
	Status.TextColor3 = Color3.fromRGB(170, 170, 190)
	Status.Font = Enum.Font.GothamMedium
	Status.TextSize = 13
	Status.TextXAlignment = Enum.TextXAlignment.Center
	Status.Parent = MainFrame
	local BarBackground = Instance.new("Frame")
	BarBackground.Size = UDim2.new(1, -40, 0, 5)
	BarBackground.Position = UDim2.new(0, 20, 0.72, 0)
	BarBackground.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
	BarBackground.BorderSizePixel = 0
	BarBackground.Parent = MainFrame
	local BarCorner = Instance.new("UICorner")
	BarCorner.CornerRadius = UDim.new(1, 0)
	BarCorner.Parent = BarBackground
	local BarProgress = Instance.new("Frame")
	BarProgress.Size = UDim2.new(0, 0, 1, 0)
	BarProgress.BackgroundColor3 = Color3.fromRGB(90, 110, 255)
	BarProgress.BorderSizePixel = 0
	BarProgress.Parent = BarBackground
	local ProgressCorner = Instance.new("UICorner")
	ProgressCorner.CornerRadius = UDim.new(1, 0)
	ProgressCorner.Parent = BarProgress
	local Gradient = Instance.new("UIGradient")
	Gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 120, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(160, 100, 255))
	})
	Gradient.Parent = BarProgress
	TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
		GroupTransparency = 0,
		Position = UDim2.new(0.5, -190, 0.5, -75)
	}):Play()
	task.wait(0.6)
	local Steps = {}
	if RuntimeSettings.SaveChoice then
		table.insert(Steps, {text = "Saving Preferences", success = "Saved!"})
	end
	table.insert(Steps, {text = "Loading Components", success = "Loaded!"})
	table.insert(Steps, {text = "Loading Bypass", success = "Bypassed game!"})
	table.insert(Steps, {text = "Loading Functions", success = "Loaded!"})
	table.insert(Steps, {text = "Loading UI", success = "Loaded!"})
	table.insert(Steps, {text = "Finalizing", success = "Loading is done!"})
	local loopActive = true
	local dotCount = 0
	local baseStepText = ""
	task.spawn(function()
		while loopActive do
			task.wait(0.3)
			if baseStepText ~= "" then
				dotCount = (dotCount + 1) % 4
				Status.Text = baseStepText .. string.rep(".", dotCount)
			end
		end
	end)
	local totalSteps = #Steps
	for idx, step in ipairs(Steps) do
		baseStepText = step.text
		local stepDuration = math.random(50, 130) / 100
		local elapsed = 0
		while elapsed < stepDuration do
			local dt = task.wait()
			elapsed = elapsed + dt
			local progressRatio = ((idx - 1) / totalSteps) + ((elapsed / stepDuration) * (1 / totalSteps))
			BarProgress.Size = UDim2.new(math.clamp(progressRatio, 0, 1), 0, 1, 0)
		end
		baseStepText = ""
		Status.Text = step.success
		Status.TextColor3 = Color3.fromRGB(80, 220, 120)
		task.wait(0.4)
		Status.TextColor3 = Color3.fromRGB(170, 170, 190)
	end
	loopActive = false
	TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {
		GroupTransparency = 1,
		Position = UDim2.new(0.5, -190, 0.5, -65)
	}):Play()
	task.wait(0.5)
	LoadingGui:Destroy()
	task.spawn(ExecuteScript)
end
local function CreateConfigurationMenu()
	local MenuGui = Instance.new("ScreenGui")
	MenuGui.Name = "OshiruMenu"
	MenuGui.ResetOnSpawn = false
	MenuGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	MenuGui.Parent = TargetGuiProtected
	local MainFrame = Instance.new("CanvasGroup")
	MainFrame.Name = "MainFrame"
	MainFrame.Size = UDim2.new(0, 350, 0, 320)
	MainFrame.Position = UDim2.new(0.5, -175, 0.5, -150)
	MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
	MainFrame.BackgroundTransparency = 0.25
	MainFrame.BorderSizePixel = 0
	MainFrame.GroupTransparency = 1
	MainFrame.Parent = MenuGui
	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(0, 16)
	UICorner.Parent = MainFrame
	local UIStroke = Instance.new("UIStroke")
	UIStroke.Thickness = 1
	UIStroke.Color = Color3.fromRGB(50, 50, 70)
	UIStroke.Transparency = 0.4
	UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	UIStroke.Parent = MainFrame
	local Title = Instance.new("TextLabel")
	Title.Size = UDim2.new(1, 0, 0, 55)
	Title.BackgroundTransparency = 1
	Title.Text = "Oshiru Setup Configuration"
	Title.TextColor3 = Color3.fromRGB(255, 255, 255)
	Title.Font = Enum.Font.GothamBold
	Title.TextSize = 15
	Title.Parent = MainFrame
	local Container = Instance.new("Frame")
	Container.Size = UDim2.new(1, -40, 1, -130)
	Container.Position = UDim2.new(0, 20, 0, 60)
	Container.BackgroundTransparency = 1
	Container.Parent = MainFrame
	local UIListLayout = Instance.new("UIListLayout")
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.Padding = UDim.new(0, 10)
	UIListLayout.Parent = Container
	local dragging, dragInput, dragStart, startPos
	local function update(input)
		local delta = input.Position - dragStart
		MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
	MainFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = MainFrame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	MainFrame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			update(input)
		end
	end)
	local TogglesData = {
		{Key = "Optimized", Label = "Optimization Mode"},
		{Key = "Debug", Label = "Debug Logging"},
		{Key = "SaveChoice", Label = "Save Chosen Options"}
	}
	for i, data in ipairs(TogglesData) do
		local Row = Instance.new("Frame")
		Row.Size = UDim2.new(1, 0, 0, 42)
		Row.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
		Row.BackgroundTransparency = 0.5
		Row.LayoutOrder = i
		Row.Parent = Container
		local RowCorner = Instance.new("UICorner")
		RowCorner.CornerRadius = UDim.new(0, 10)
		RowCorner.Parent = Row
		local RowStroke = Instance.new("UIStroke")
		RowStroke.Thickness = 1
		RowStroke.Color = Color3.fromRGB(45, 45, 60)
		RowStroke.Transparency = 0.6
		RowStroke.Parent = Row
		local Label = Instance.new("TextLabel")
		Label.Size = UDim2.new(0.7, 0, 1, 0)
		Label.Position = UDim2.new(0, 12, 0, 0)
		Label.BackgroundTransparency = 1
		Label.Text = data.Label
		Label.TextColor3 = Color3.fromRGB(200, 200, 215)
		Label.Font = Enum.Font.GothamMedium
		Label.TextSize = 13
		Label.TextXAlignment = Enum.TextXAlignment.Left
		Label.Parent = Row
		local ToggleContainer = Instance.new("TextButton")
		ToggleContainer.Size = UDim2.new(0, 44, 0, 22)
		ToggleContainer.Position = UDim2.new(1, -56, 0.5, -11)
		ToggleContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
		ToggleContainer.Text = ""
		ToggleContainer.AutoButtonColor = false
		ToggleContainer.Parent = Row
		local ToggleCorner = Instance.new("UICorner")
		ToggleCorner.CornerRadius = UDim.new(1, 0)
		ToggleCorner.Parent = ToggleContainer
		local ToggleStroke = Instance.new("UIStroke")
		ToggleStroke.Thickness = 1
		ToggleStroke.Color = Color3.fromRGB(55, 55, 70)
		ToggleStroke.Parent = ToggleContainer
		local ToggleCircle = Instance.new("Frame")
		ToggleCircle.Size = UDim2.new(0, 16, 0, 16)
		ToggleCircle.Position = UDim2.new(0, 3, 0.5, -8)
		ToggleCircle.BackgroundColor3 = Color3.fromRGB(150, 150, 165)
		ToggleCircle.BorderSizePixel = 0
		ToggleCircle.Parent = ToggleContainer
		local CircleCorner = Instance.new("UICorner")
		CircleCorner.CornerRadius = UDim.new(1, 0)
		CircleCorner.Parent = ToggleCircle
		Row.MouseEnter:Connect(function()
			TweenService:Create(Row, TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				BackgroundTransparency = 0.2
			}):Play()
		end)
		Row.MouseLeave:Connect(function()
			TweenService:Create(Row, TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				BackgroundTransparency = 0.5
			}):Play()
		end)
		ToggleContainer.MouseButton1Click:Connect(function()
			RuntimeSettings[data.Key] = not RuntimeSettings[data.Key]
			if RuntimeSettings[data.Key] then
				TweenService:Create(ToggleContainer, TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
					BackgroundColor3 = Color3.fromRGB(90, 110, 255)
				}):Play()
				TweenService:Create(ToggleStroke, TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
					Color = Color3.fromRGB(130, 150, 255)
				}):Play()
				TweenService:Create(ToggleCircle, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Position = UDim2.new(1, -19, 0.5, -8),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				}):Play()
			else
				TweenService:Create(ToggleContainer, TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
					BackgroundColor3 = Color3.fromRGB(35, 35, 48)
				}):Play()
				TweenService:Create(ToggleStroke, TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
					Color = Color3.fromRGB(55, 55, 70)
				}):Play()
				TweenService:Create(ToggleCircle, TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
					Position = UDim2.new(0, 3, 0.5, -8),
					BackgroundColor3 = Color3.fromRGB(150, 150, 165)
				}):Play()
			end
		end)
	end
	local RunButton = Instance.new("TextButton")
	RunButton.Size = UDim2.new(1, -40, 0, 44)
	RunButton.Position = UDim2.new(0, 20, 1, -64)
	RunButton.BackgroundColor3 = Color3.fromRGB(90, 110, 255)
	RunButton.Text = "Run Script"
	RunButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	RunButton.Font = Enum.Font.GothamBold
	RunButton.TextSize = 13
	RunButton.AutoButtonColor = false
	RunButton.Parent = MainFrame
	local ButtonCorner = Instance.new("UICorner")
	ButtonCorner.CornerRadius = UDim.new(0, 12)
	ButtonCorner.Parent = RunButton
	local ButtonGradient = Instance.new("UIGradient")
	ButtonGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(90, 110, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 90, 255))
	})
	ButtonGradient.Parent = RunButton
	RunButton.MouseEnter:Connect(function()
		TweenService:Create(RunButton, TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
			Size = UDim2.new(1, -36, 0, 46),
			Position = UDim2.new(0, 18, 1, -65)
		}):Play()
	end)
	RunButton.MouseLeave:Connect(function()
		TweenService:Create(RunButton, TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
			Size = UDim2.new(1, -40, 0, 44),
			Position = UDim2.new(0, 20, 1, -64)
		}):Play()
	end)
	RunButton.MouseButton1Down:Connect(function()
		TweenService:Create(RunButton, TweenInfo.new(0.1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
			Size = UDim2.new(1, -44, 0, 42),
			Position = UDim2.new(0, 22, 1, -63)
		}):Play()
	end)
	RunButton.MouseButton1Up:Connect(function()
		TweenService:Create(RunButton, TweenInfo.new(0.1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
			Size = UDim2.new(1, -36, 0, 46),
			Position = UDim2.new(0, 18, 1, -65)
		}):Play()
	end)
	RunButton.MouseButton1Click:Connect(function()
		if RuntimeSettings.SaveChoice then
			SaveConfiguration()
		else
			if isfile(ConfigFile) then
				pcall(delfile, ConfigFile)
			end
		end
		TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {
			GroupTransparency = 1,
			Position = UDim2.new(0.5, -175, 0.5, -140)
		}):Play()
		task.wait(0.4)
		MenuGui:Destroy()
		task.spawn(LaunchLoadingUI)
	end)
	TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
		GroupTransparency = 0,
		Position = UDim2.new(0.5, -175, 0.5, -160)
	}):Play()
end
local SavedConfig = LoadConfiguration()
if SavedConfig and SavedConfig.SaveChoice then
	RuntimeSettings = SavedConfig
	task.spawn(LaunchLoadingUI)
else
	task.spawn(CreateConfigurationMenu)
end
