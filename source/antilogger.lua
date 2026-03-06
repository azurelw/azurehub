local HttpService = cloneref(game:GetService("HttpService"))

local blacklistedurls = {"iplogger", "grabify", "stopify", "blasze", "leancoding", "ip-api", "ipify", "ipaddress", "checkip", "ifconfig", "browserleaks", "whoer", "rawscriptserver", "hookdeck", "ngrok", "snyk"}

local old
old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if self == HttpService and (method == "PostAsync" or method == "GetAsync" or method:find("Request")) then
        local url = tostring(args[1]):lower()
        local blocked = false

        if url:find("discord.com/api/webhooks") or url:find("guilded.gg/api/webhooks") or url:find("ip") then
            blocked = true
        end

        for _, domain in ipairs(blacklistedurls) do
            if url:find(domain) then
                blocked = true
                break
            end
        end
        
        if customurls then
            for _, domain in ipairs(customurls) do
                if url:find(domain) then
                    blocked = true
                    break
                end
            end
        end

        if blocked then
            warn("Blocked URL: " .. tostring(args[1]))
            if method:find("Request") then
                return {
                    Success = true,
                    StatusCode = 200,
                    Body = "{\"status\":\"success\"}" 
                }
            end
            return nil
        end
    end
    return old(self, ...)
end))

local function hook(reqFunc)
    if not reqFunc then return end
    
    local oldReq
    oldReq = hookfunction(reqFunc, newcclosure(function(options)
        local url = tostring(options.Url):lower()
        local blocked = false

        if url:find("discord.com/api/webhooks") or url:find("guilded.gg/api/webhooks") or url:find("ip") then
            blocked = true
        end

        for _, domain in ipairs(blacklistedurls) do
            if url:find(domain) then
                blocked = true
                break
            end
        end
        
        if customurls then
            for _, domain in ipairs(customurls) do
                if url:find(domain) then
                    blocked = true
                    break
                end
            end
        end

        if blocked then
            warn("Blocked URL: " .. options.Url)
            return {
                Success = true,
                StatusCode = 200,
                Body = "{\"status\":\"success\"}"
            }
        end

        return oldReq(options)
    end))
end

hook(getgenv().request)
hook(getgenv().http_request)
hook(request)
hook(http_request)
if syn then hook(syn.request) end
if http then hook(http.request) end

local oldType
oldType = hookfunction(type, newcclosure(function(value)
    if value == restorefunction or value == detour_restore or value == restore_function then
        hook(getgenv().request)
        hook(getgenv().http_request)
        hook(request)
        hook(http_request)
        return "random"
    end
    return oldType(value)
end))

print("Anti webhook & IP logger active.")
