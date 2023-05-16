import Debug "mo:base/Debug";
import {
  assertTrue;
  describe;
  it;
  run;
} "mo:mospec/MoSpec";
import Main "main";

let backendActor = await Main.ObsidianTearsBackend();

let success = run([
  describe(
    "#checkIn",
    [
      it(
        "should greet me",
        do {
          let response = await backendActor.checkIn();
          assertTrue(response == ());
        },
      ),
    ],
  ),
]);

if (success == false) {
  Debug.trap("Tests failed");
};
