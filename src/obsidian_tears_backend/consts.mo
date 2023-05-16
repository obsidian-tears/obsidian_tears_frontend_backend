import Time "mo:base/Time";

module {
  public let SESSION_LIFE : Time.Time = 86_400_000_000_000; // remove sessions after 24 hr (clear gain limits)
  public let SESSION_CHECK : Time.Time = 3_600_000_000_000; // check sessions every 1 hr
  public let REGISTRY_CHECK : Time.Time = 600_000_000_000; // check sessions every 10 minutes
  public let MAX_GOLD : Nat32 = 5_000; // max amount of gold earned in 1 session
  public let MAX_XP : Nat32 = 5_000; // max amount of gold earned in 1 session
  public let MAX_ITEMS : Nat8 = 100; // max amount of gold earned in 1 session
};
