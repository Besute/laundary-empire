-- ItemConfig: laundry pieces, shop supplies and cleaning tools.
local I = {}

-- Pieces customers bring. Units = CapacityUnits. Fabric drives wash/dry mode fit.
I.Laundry = {
	Shirt = { Id = "Shirt", Units = 1, Price = 10, Fabric = "Normal", Level = 1, Color = Color3.fromRGB(120, 180, 240) },
	Jeans = { Id = "Jeans", Units = 2, Price = 16, Fabric = "Heavy", Level = 1, Color = Color3.fromRGB(60, 90, 160) },
	Towel = { Id = "Towel", Units = 1, Price = 12, Fabric = "Heavy", Level = 1, Color = Color3.fromRGB(240, 240, 235) },
	DressShirt = { Id = "DressShirt", Units = 1, Price = 14, Fabric = "Normal", Level = 2, Color = Color3.fromRGB(245, 245, 250) },
	Bedding = { Id = "Bedding", Units = 3, Price = 28, Fabric = "Heavy", Level = 3, Color = Color3.fromRGB(235, 205, 220) },
	Delicates = { Id = "Delicates", Units = 1, Price = 22, Fabric = "Delicate", Level = 4, Color = Color3.fromRGB(230, 190, 240) },
}
I.LaundryOrder = { "Shirt", "Jeans", "Towel", "DressShirt", "Bedding", "Delicates" } -- stable display order

-- Supplies. Inventory counts DOSES; shop sells packs of PackSize doses for Price.
-- Kind: "Detergent" (required main product for a wash cycle), "Additive" (optional), "Tool", "Part".
I.Supplies = {
	Detergent_Regular = { Id = "Detergent_Regular", Kind = "Detergent", Price = 30, PackSize = 8, Level = 1, Power = 0.0, QualityBonus = 0.00, Fabrics = { Normal = 1.0, Heavy = 1.0, Delicate = 0.7 } },
	Detergent_Pro = { Id = "Detergent_Pro", Kind = "Detergent", Price = 80, PackSize = 8, Level = 3, Power = 0.2, QualityBonus = 0.06, Fabrics = { Normal = 1.0, Heavy = 1.05, Delicate = 0.8 } },
	Detergent_Delicate = { Id = "Detergent_Delicate", Kind = "Detergent", Price = 55, PackSize = 8, Level = 4, Power = -0.1, QualityBonus = 0.00, Fabrics = { Normal = 0.9, Heavy = 0.75, Delicate = 1.15 } },
	Additive_Softener = { Id = "Additive_Softener", Kind = "Additive", Price = 40, PackSize = 8, Level = 2, QualityBonus = 0.04 },
	Additive_Bleach = { Id = "Additive_Bleach", Kind = "Additive", Price = 35, PackSize = 8, Level = 3, QualityBonus = 0.02, WhitesBonus = 0.06, BadFor = "Delicate" },
	Additive_StainRemover = { Id = "Additive_StainRemover", Kind = "Additive", Price = 45, PackSize = 8, Level = 3, Power = 0.25 },
	Additive_Scent = { Id = "Additive_Scent", Kind = "Additive", Price = 50, PackSize = 8, Level = 5, TipBonus = 0.15 },
	Tool_Broom = { Id = "Tool_Broom", Kind = "Tool", Price = 100, PackSize = 1, Level = 1, Tool = "Broom", Owned = true }, -- granted at start
	Tool_Mop = { Id = "Tool_Mop", Kind = "Tool", Price = 150, PackSize = 1, Level = 3, Tool = "Mop" },
	Tool_Vacuum = { Id = "Tool_Vacuum", Kind = "Tool", Price = 250, PackSize = 1, Level = 6, Tool = "Vacuum" },
	SpareParts = { Id = "SpareParts", Kind = "Part", Price = 90, PackSize = 3, Level = 4 },
}
I.SupplyOrder = {
	"Detergent_Regular", "Detergent_Pro", "Detergent_Delicate",
	"Additive_Softener", "Additive_Bleach", "Additive_StainRemover", "Additive_Scent",
	"Tool_Mop", "Tool_Vacuum", "SpareParts",
}

I.StartingInventory = { Detergent_Regular = 12, Tool_Broom = 1 }
I.BaseStorage = 40 -- storage units; each dose / part takes 1 (tools do not count)

function I.isConsumable(id)
	local s = I.Supplies[id]
	return s ~= nil and (s.Kind == "Detergent" or s.Kind == "Additive" or s.Kind == "Part")
end

return I
