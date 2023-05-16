import Debug "mo:base/Debug";
import CanisterActor "Canister";
import MoSpec "../src/MoSpec";

let deployedCanister = await CanisterActor.Canister();

let assertTrue = MoSpec.assertTrue;
let describe = MoSpec.describe;
let context = MoSpec.context;
let before = MoSpec.before;
let it = MoSpec.it;
let skip = MoSpec.skip;
let pending = MoSpec.pending;
let run = MoSpec.run;

let success = run([
  describe(
    "#greet",
    [
      it(
        "should greet me",
        do {
          let response = await deployedCanister.greet({ name = "Christoph" });
          assertTrue(response == "Hello, Christoph!");
        },
      ),
      it(
        "greet him-whose-name-shall-not-be-spoken",
        do {
          let response = await deployedCanister.greet({
            name = "him whose name shall not be spoken";
          });
          assertTrue(response != "Voldemort");
        },
      ),
    ],
  ),
  describe(
    "#sum",
    [
      it(
        "should sum two positive Nats",
        do {
          let response = await deployedCanister.sum((1, 2));
          assertTrue(response == 3);
        },
      ),
      it(
        "should fail a check that doesn't match",
        do {
          let response = await deployedCanister.sum((1, 2));
          assertTrue(response != 4);
        },
      ),
    ],
  ),
]);

if (success == false) {
  Debug.trap("Tests failed");
};
