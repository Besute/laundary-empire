-- ErrorCodes: every Result{ok=false, code=...} uses one of these. Client maps them to Loc keys "err.<Code>".
return {
	"NotLoaded", "RateLimited", "InvalidArgs", "NotFound", "NotOwner", "OutOfRange", "Locked", "NotEnoughCash", "NotEnoughItems",
	"NoSupplies", "OverCapacity", "InvalidState", "Busy", "Broken", "Incompatible", "OutOfBounds", "Overlap", "Reserved", "MaxReached",
	"AlreadyOwned", "RequirementMissing", "StorageFull", "NameRejected", "ServerError", "Closed", "NoPlot", "NoCounter", "Duplicate",
	"InvalidFloor", "NoFreeSpot", "NotReady", "NothingToDo", "TooEarly",
}
