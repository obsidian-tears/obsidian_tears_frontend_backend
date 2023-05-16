# Architecture

A few concepts / components that are important to understand, will be described in the sections below.

## Runner

The executable that is being called and that actually runs all the specs. It is using the package mo-dev/mo-test underneath the hood.

The package collects all files ending in \*.test.mo, it executes them with wasmtime testmode and then runs each test. It collects data of how many were success, failed or skipped and presents a summary at the end.

## Config

Where you can set the configs that affect ALL specs. Good examples would be: environment vars, some bootstrap config, strategies for cleaning up data, enable/disable extensions and it's configs, etc.

## Support Directory

Would be any outside library or supporting file to be used by the specs.

The use of **factories** are very common to mock input to the functions being tested. Allowing for these objects to be reused by several specs.

**Matchers** are needed because we want to be expressive whenever a message fails. So if a string is different, it can say "expected Foo, but got Bar". Things can easily complicate when needing to handle a Result record or checking if a Key / Value is present inside a HashMap. You will want to have a Matcher to help you out on these.

Another common use is the **recordings** of intercanister calls. If a pipeline is dependent on a live response, it will wait ~2 seconds for an update request, and this easily "slows down" a pipeline.
Plus, any dependency on an external canister is unnecessarily risky, as the canister could be temporarily down and you can't deploy your code.

As a project scales you will want to control "when to look deeper and fix" an integration test. To make it easy, you will want to use recordings, that are automatically recorded and replayed. If anything comes up, it's easy to recreate a recording, or if you want to deeply check your integration tests, just run specs without replay.

## Spec Files (\*.test.mo)

Last but not least, **specs** are the files/modules where you will write the specs in a clear 3 step layer:

- Setup
- Execute
- Assert

You should have one "spec file" per "src file" being tested, finishing with a \*.test.mo. Although it can be in a separate "spec" folder as in traditional testing libraries, the
recommended structure for MoSpec is on the same folder as src, following the trend on Jest. It allows for easier import, easier "access" and tracking of which files are being tested, etc.

You should use descriptive strings, with the "describe", "context" and "it" blocks. Also variables should be descriptive. So that any future developer can easily skim through the english part, and only stop at the edge case that is relevant.
