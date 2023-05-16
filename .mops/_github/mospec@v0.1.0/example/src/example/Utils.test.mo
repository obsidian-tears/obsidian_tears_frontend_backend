import U "Utils";
import Debug "mo:base/Debug";
import MoSpec "../../../src/MoSpec";

let assertTrue = MoSpec.assertTrue;
let describe = MoSpec.describe;
let context = MoSpec.context;
let before = MoSpec.before;
let it = MoSpec.it;
let skip = MoSpec.skip;
let pending = MoSpec.pending;
let run = MoSpec.run;

// setup
var iterator = 0;

let success = run([
  describe(
    "#sum",
    [
      before(
        do {
          iterator += 1;
        }
      ),
      context(
        "when something happens",
        [
          it(
            "should assess a boolean value",
            do {
              assertTrue(true);
            },
          ),
          it(
            "should sum two positive Nats",
            do {
              assertTrue(U.sum((1, 2)) == 3);
            },
          ),
          it(
            "should check that doesn't match",
            do {
              assertTrue(U.sum((1, 2)) != 4);
            },
          ),
          it(
            "before do should have run 1 times",
            do {
              assertTrue(iterator == 1);
            },
          ),
          skip(
            "should skip a test",
            do {
              // Useful for defining a test that is not yet implemented
              true;
            },
          ),
        ],
      ),
    ],
  ),
]);

if (success == false) {
  Debug.trap("Tests failed");
};
