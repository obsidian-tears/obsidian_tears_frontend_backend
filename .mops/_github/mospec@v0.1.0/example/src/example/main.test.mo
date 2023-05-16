import Debug "mo:base/Debug";
import Main "main";
import MoSpec "../../../src/MoSpec";

let exampleCanister = await Main.ExampleCanister();

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
          let response = await exampleCanister.greet({ name = "Christoph" });
          assertTrue(response == "Hello, Christoph!");
        },
      ),
      it(
        "greet him-whose-name-shall-not-be-spoken",
        do {
          let response = await exampleCanister.greet({
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
          let response = await exampleCanister.sum((1, 2));
          assertTrue(response == 3);
        },
      ),
      it(
        "should fail a check that doesn't match",
        do {
          let response = await exampleCanister.sum((1, 2));
          assertTrue(response != 4);
        },
      ),
    ],
  ),
]);

if (success == false) {
  Debug.trap("Tests failed");
};
