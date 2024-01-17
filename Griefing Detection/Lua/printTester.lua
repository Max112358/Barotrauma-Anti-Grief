if CLIENT then return end -- stops this from running on the client

Hook.Add("serverLog", "printFromServerChecker", function (text, serverLogMessageType)

	print("the hook from the server is working and visible")

end)
