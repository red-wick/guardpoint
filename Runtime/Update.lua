local frame = CreateFrame("Frame")

frame:SetScript("OnUpdate", function(self, elapsed)
    Guardpoint.Scheduler:RunDue()
end)
