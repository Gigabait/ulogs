--[[
    
     _   _  _  _    _                    _           _                        
    | | | || || |  (_)                  | |         | |                       
    | | | || || |_  _  _ __ ___    __ _ | |_   ___  | |      ___    __ _  ___ 
    | | | || || __|| || '_ ` _ \  / _` || __| / _ \ | |     / _ \  / _` |/ __|
    | |_| || || |_ | || | | | | || (_| || |_ |  __/ | |____| (_) || (_| |\__ \
     \___/ |_| \__||_||_| |_| |_| \__,_| \__| \___| \_____/ \___/  \__, ||___/
                                                                    __/ |     
                                                                   |___/      
    
    
]]--





ULogs = ULogs or {}
ULogs.LogTypes = ULogs.LogTypes or {}
ULogs.GMTypes = ULogs.GMTypes or {}

local Data = {}
Data.ID = 1
Data.GM = 0
Data.Name = "ALL Logs"
Data.Register = function() end

ULogs.LogTypes[ 1 ] = Data





----------------------------------------------------------------------------------
--
-- Functions
--
----------------------------------------------------------------------------------



ULogs.AddLogType = function( ID, GM, Name, Register )
	
	if !ID then return end
	if !GM then return end
	if !Name then return end
	if type( Register ) != "function" then return end
	
	if ID == 1 then Error( "[UltimateLogs] LogID : " .. ID .. " is invalid \n" ) return end
	if ULogs.LogTypes[ ID ] then Error( "[UltimateLogs] LogID : " .. ID .. " already exists \n" ) end
	
	local Data = {}
	Data.ID = ID
	Data.GM = GM
	Data.Name = Name
	Data.Register = Register
	
	ULogs.LogTypes[ ID ] = Data
	
end

ULogs.AddGMType = function( ID, Name )
	
	if !ID then return end
	if !Name then return end
	
	if ID == 0 then Error( "[UltimateLogs] GM ID : " .. ID .. " is invalid \n" ) return end
	if ULogs.GMTypes[ ID ] then Error( "[UltimateLogs] GM ID : " .. ID .. " already exists \n" ) end
	
	local Data = {}
	Data.ID = ID
	Data.Name = Name
	
	ULogs.GMTypes[ ID ] = Data
	
end

CAMI.RegisterPrivilege( { Name = "ULogs.See",    MinAccess = ULogs.config.CanSee or "admin" } )
CAMI.RegisterPrivilege( { Name = "ULogs.SeeIP",  MinAccess = ULogs.config.CanSeeIP or "superadmin" } )
CAMI.RegisterPrivilege( { Name = "ULogs.Delete", MinAccess = ULogs.config.CanDelete or "superadmin" } )

ULogs.CAMI = {}
ULogs.CAMI.Privileges = {}
ULogs.CAMI.Privileges.See = {}
ULogs.CAMI.Privileges.SeeIP = {}
ULogs.CAMI.Privileges.Delete = {}

ULogs.CAMI.GetPlayersWithAccess = function( privilegeName, callback )
	
	local allowedPlys = {}
	local allPlys = player.GetAll()
	
	local function onResult( k, ply, hasAccess, _ )
		
		if hasAccess then table.insert(allowedPlys, ply) end
		if k >= #allPlys then callback( allowedPlys ) end
		
	end
	
	for k, v in pairs( allPlys ) do
		
		CAMI.PlayerHasAccess( v, privilegeName, function( ... ) onResult( k, v, ... ) end, v )
		
	end
	
end

ULogs.CAMI.Refresh = function()
	
	ULogs.CAMI.GetPlayersWithAccess( "ULogs.See", function( Players ) ULogs.CAMI.Privileges.See = Players end)
	ULogs.CAMI.GetPlayersWithAccess( "ULogs.SeeIP", function( Players ) ULogs.CAMI.Privileges.SeeIP = Players end)
	ULogs.CAMI.GetPlayersWithAccess( "ULogs.Delete", function( Players ) ULogs.CAMI.Privileges.Delete = Players end)
	
end

-- I have to use a timer because a lot of admin addons call hooks before changing players ranks...
hook.Add( "CAMI.OnUsergroupRegistered", "ULogs_CAMI_OnUsergroupRegistered", function() timer.Simple( 1, function() ULogs.CAMI.Refresh() end) end)
hook.Add( "CAMI.OnUsergroupUnregistered", "ULogs_CAMI_OnUsergroupUnregistered", function() timer.Simple( 1, function() ULogs.CAMI.Refresh() end) end)
hook.Add( "CAMI.PlayerUsergroupChanged", "ULogs_CAMI_PlayerUsergroupChanged", function() timer.Simple( 1, function() ULogs.CAMI.Refresh() end) end)
hook.Add( "CAMI.SteamIDUsergroupChanged", "ULogs_CAMI_SteamIDUsergroupChanged", function() timer.Simple( 1, function() ULogs.CAMI.Refresh() end) end)
hook.Add( "PlayerInitialSpawn", "ULogs_CAMI_PlayerInitialSpawn", function() timer.Simple( 1, function() ULogs.CAMI.Refresh() end) end)
hook.Add( "UCLChanged", "ULogs_CAMI_UCLChanged", function() timer.Simple( 1, function() ULogs.CAMI.Refresh() end) end)
timer.Create( "ULogs_CAMI_Refresh", 30, 0, function() ULogs.CAMI.Refresh() end)
ULogs.CAMI.Refresh()




