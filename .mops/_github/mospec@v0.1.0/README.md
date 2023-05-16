# MoSpec

Motoko specs that are easy to read and learn, allowing you to ship Motoko code with confidence.

## Notice

This is a heavily WIP package

## Credits

- Underneath the hood, it's using "mo-test" command of [mo-dev (npm package)](https://www.npmjs.com/package/mo-dev) of [Ryan Vandersmith](https://github.com/rvanasa)
- Empowered by [Motoko Matchers](https://kritzcreek.github.io/motoko-matchers) of [Christoph Hegemann](https://github.com/kritzcreek)
- Empowered by [ActorSpec](https://github.com/dfinity/motoko-base/tree/e4efcb9bbd8c8eeff41b3d461b679e43d1d66f44/examples/actorspec) of [Joachim Breitner](https://github.com/nomeata)
- Based on the example [Motoko Unit Tests](https://github.com/krpeacock/motoko-unit-tests) of [Kyle Peacock](https://github.com/krpeacock)
- Based on the example of packages testing in [Motoko Base](https://github.com/dfinity/motoko-base/)
- Heavily inspired by other Spec frameworks, mostly RSpec, but also Jest.

## Demo

In this repo, you will find an example of it's usage on the "example" folder. (WIP)

## Features

- Fast and powerful spec loader and runner (credit to mo-test)
- "Describe", "context", "before", "it" syntax, with grouping and sub-grouping
- Capable of running Canister / Actor specs, using the interpreter
-

[Next Features](/ROADMAP.md)

---

## Architecture

There are some concepts and architectural choices that is important to understand for any project to apply this library succesfuly.

**MoSpec**, in your project will be composed of:

- Spec Config
- Spec Support
- Specs

[Learn more about Architecture](/ARCHITECTURE.md)
