import Debug "mo:base/Debug";
import MoSpec "mo:mospec/MoSpec";

import Main "main";

let exampleCanister = await Main.ObsidianTearsRpg();

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
    "#checkIn",
    [
      it(
        "should greet me",
        do {
          let response = await exampleCanister.checkIn();
          assertTrue(response == ());
        },
      ),
    ],
  ),
]);

if (success == false) {
  Debug.trap("Tests failed");
};
