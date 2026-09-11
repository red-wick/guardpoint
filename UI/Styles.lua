Guardpoint.UI = Guardpoint.UI or {}

local UI = Guardpoint.UI

UI.Styles = UI.Styles or {}
local Styles = UI.Styles

Styles.FONT_SIZE = 12

function Styles:ApplyText(fontString, size)
    if not fontString then
        return false
    end

    fontString:SetTextHeight(size or self.FONT_SIZE)
    return true
end

function Styles:ApplyFrame(frame)
    if not frame then
        return false
    end

    frame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    frame:SetBackdropColor(0, 0, 0, 0.85)
    frame:SetBackdropBorderColor(0.7, 0.7, 0.7, 1)
    return true
end
