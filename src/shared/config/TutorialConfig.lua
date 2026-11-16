-- TutorialConfig: GDD §4 steps. Progress is server-side (TutorialService) and advances on bus events.
local T = {}

-- Event names are Bus events (server) emitted by services; ReportUIEvent can raise "BuildMenuOpened" / "BusinessMenuOpened".
-- Filter: optional {Kind="Washer"} matched against the event payload's Kind field.
-- Target tells the client what to highlight: {Button="BuildButton"} | {CatalogItem="Washer_Basic"} | {ObjectKind="Counter"} | {Machine="Washer"}
T.Steps = {
	{ Id = "T0", Event = "BusinessSetup", TextKey = "tut.T0", Target = { Button = "SetupConfirm" } },
	{ Id = "T1", Event = "BuildMenuOpened", TextKey = "tut.T1", Target = { Button = "BuildButton" } },
	{ Id = "T2", Event = "ObjectPlaced", Filter = { Kind = "Washer" }, TextKey = "tut.T2", Target = { CatalogItem = "Washer_Basic" } },
	{ Id = "T3", Event = "ObjectPlaced", Filter = { Kind = "Dryer" }, TextKey = "tut.T3", Target = { CatalogItem = "Dryer_Basic" } },
	{ Id = "T4", Event = "ObjectPlaced", Filter = { Kind = "Counter" }, TextKey = "tut.T4", Target = { CatalogItem = "Counter_Basic" } },
	{ Id = "T5", Event = "BusinessMenuOpened", TextKey = "tut.T5", Target = { Button = "BusinessButton" } },
	{ Id = "T6", Event = "BusinessSettingsSaved", TextKey = "tut.T6", Target = { Button = "BusinessSave" } },
	{ Id = "T7", Event = "BusinessOpened", TextKey = "tut.T7", Target = { Button = "BusinessToggle" } },
	{ Id = "T8", Event = "OrderAccepted", TextKey = "tut.T8", Target = { ObjectKind = "Counter" } },
	{ Id = "T9", Event = "OrderReady", TextKey = "tut.T9", Target = { Machine = "Washer" } },
	{ Id = "T10", Event = "OrderCompleted", TextKey = "tut.T10", Target = { ObjectKind = "Counter" } },
}
T.CompletionReward = { Cash = 400, XP = 30 }

return T
