-- Guardpoint slash commands
local NS = _G.Guardpoint
local S=NS.State.data;local U=NS.Util;local P=NS.Planner;local UI=NS.UI;local X=NS.Runtime

-- Use a unique slash-command key so no other addon/server command can collide with it.
SLASH_GUARDPOINT_GP1="/guardpoint"
SLASH_GUARDPOINT_GP2="/gp"
SlashCmdList["GUARDPOINT_GP"]=function(msg)
    msg=U.lower(msg)
    if msg=="" or msg=="help" then
        DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffGuardpoint|r: /guardpoint test | pre | p2 | p3 | reset | show | hide | lock | unlock | 4t10 on/off/auto")
    elseif msg=="test" then
        S.test=true;S.encounter=false;S.active=true;S.phase=2;S.reaper=S.reaper+1;if S.reaper>8 then S.reaper=1 end
        S.expire=U.now()+((NS.LichKing and NS.LichKing.Timing and NS.LichKing.Timing.ReaperDuration) or 5.1);S.nextAt=nil;S.used={}
        local b,a,pair=P.buildPlan(S.phase,S.reaper,S.expire);S.plan={before=b,after=a}
        if pair and S.phase==2 and S.reaper==3 then S.corePair={};for i=1,#pair do S.corePair[#S.corePair+1]=U.copy(pair[i]) end end
        UI.render();DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffGP|r test: P"..S.phase.." Жнец #"..S.reaper)
    elseif msg=="pre" then
        S.test=false;S.active=false;S.reaper=0;S.nextNumber=1;S.nextAt=U.now()+((NS.LichKing and NS.LichKing.Timing and NS.LichKing.Timing.Prewarn) or 8.0);S.plan=nil;UI.frame:Hide()
        DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffGP|r pre: P2 Жнец #1 через 8 сек")
    elseif msg=="p2" then X.phaseReset(2);DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffGP|r P2")
    elseif msg=="p3" then X.phaseReset(3);DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffGP|r P3")
    elseif msg=="reset" then X.phaseReset(2);DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffGP|r reset")
    elseif msg=="show" then UI.create();UI.frame:Show();UI.frame.timer:SetText("TEST")
    elseif msg=="hide" then UI.frame:Hide()
    elseif msg=="lock" then S.DB.locked=true;DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffGP|r locked")
    elseif msg=="unlock" then S.DB.locked=false;DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffGP|r unlocked")
    elseif msg=="4t10 on" then S.t10Override=true;DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffGP|r 4T10 ON")
    elseif msg=="4t10 off" then S.t10Override=false;DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffGP|r 4T10 OFF")
    elseif msg=="4t10 auto" then S.t10Override=nil;DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffGP|r 4T10 AUTO")
    else DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffGP|r неизвестная команда. /guardpoint help") end
end
if S.DB.locked==nil then S.DB.locked=false end
