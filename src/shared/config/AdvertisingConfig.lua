-- AdvertisingConfig: campaigns raise ChoiceScore.Advertising; they never create customers by themselves.
local A = {}

-- Physical slots in the world; ids are fixed so server, world builder and client agree.
A.SlotIds = { "Banner1", "Banner2", "Billboard1", "Billboard2", "Billboard3", "BusStop1", "BusStop2", "Digital1", "Digital2" }
A.SlotTypeOf = { Banner1 = "Banner", Banner2 = "Banner", Billboard1 = "Billboard", Billboard2 = "Billboard", Billboard3 = "Billboard", BusStop1 = "BusStop", BusStop2 = "BusStop", Digital1 = "Digital", Digital2 = "Digital" }

-- Seconds count only while the owner is online (no offline production, GDD).
A.Campaigns = {
	Flyers = { Id = "Flyers", Price = 60, Duration = 600, Boost = 0.05, Level = 1, SlotType = nil },
	Banner = { Id = "Banner", Price = 250, Duration = 1200, Boost = 0.10, Level = 3, SlotType = "Banner" },
	Billboard = { Id = "Billboard", Price = 700, Duration = 1500, Boost = 0.18, Level = 6, SlotType = "Billboard" },
	BusStop = { Id = "BusStop", Price = 450, Duration = 1200, Boost = 0.12, Level = 4, SlotType = "BusStop" },
	Digital = { Id = "Digital", Price = 900, Duration = 1500, Boost = 0.20, Level = 9, SlotType = "Digital" },
	Internet = { Id = "Internet", Price = 600, Duration = 1800, Boost = 0.15, Level = 5, SlotType = nil },
	CityWide = { Id = "CityWide", Price = 2500, Duration = 2100, Boost = 0.35, Level = 15, SlotType = nil },
}
A.Order = { "Flyers", "Banner", "BusStop", "Internet", "Billboard", "Digital", "CityWide" }
A.MaxActivePerPlayer = 4 -- one campaign per type at a time
A.MaxBoost = 1.0

return A
