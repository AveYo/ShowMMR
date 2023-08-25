--	ShowTime dashboard mod by AveYo, 2023.08.24	--

if not IsServer() then return end -- local lua server instance only

if ShowTime == nil then ShowTime = class({}) end

function ShowTime:Init(i, e)
	if CustomGameEventManager then
		CustomGameEventManager:RegisterListener("ShowTime_DST", function(...) return ShowTime:DST(...) end)
	end
end

function ShowTime:DST(i, e)
	local lt, dst = LocalTime(), -2
	local h1, m1, s1, h2, m2, s2 = e.h, e.m, e.s, lt.Hours, lt.Minutes, lt.Seconds
	if h1 == 0 then h1 = 24 end
	if h2 == 0 then h2 = 24 end
	local t1, t2 = h1 * 3600 + m1 * 60 + s1, h2 * 3600 + m2 * 60 + s2 
	if t2 - t1 > 3599 then dst = -1 end 
	if t1 - t2 > 3599 then dst = -1 end
	cvar_setf('cl_showmem', dst)
	--print(h1,m1,s1,t1,t1-t2,' > ',h2,m2,s2,t2,t2-t1)
end

ListenToGameEvent('player_connect_full', Dynamic_Wrap(ShowTime, 'Init'), ShowTime)
