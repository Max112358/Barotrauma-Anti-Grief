if SERVER then return end --prevents it from running on the server



AntiGrief.round_has_ended = false



Hook.Add("roundEnd", "AntiGriefRoundHasEnded", function ()
    --doRoundEndFunctions()
    AntiGrief.round_has_ended = true
end)


Hook.Add("roundStart", "AntiGriefRoundHasStarted", function ()
    --doRoundEndFunctions()
    AntiGrief.round_has_ended = false
end)

