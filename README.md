# Aergo Contract Example

Aergo, as a distributed application and storage platform, want as many developers as possible to realize their ideas on the blockchain.
So we create and provide generally and frequently used libraries and some examples that existing dapp developers would find friendly.

## Libraries

* safemath: It is a library used to prevent overflow, divide-by-zero, etc...
* address: It is an utility library to verify addresses used in aergo.
* object: Lua does not provide classes. This is a library that helps you write reusable code using lua tables.
* typecheck: Provides a library that increases the readability and checks the type.

## Smart Contracts

* helloworld: It is a very basic contract. You can learn how to use set and get.
* fixedtoken: This is an example of a token contract with a fixed amount of issuance.
* exchange: It is a simple token <-> aergo exchange contract.
* crowdsale: Using the object library, we provide a reusable crowdsale contract.
* sqlwrapper: It is a simple contract that can execute and query SQL to blockchain directly.
* token: It is a token contract referring to erc20. It can be combined with the object library depending on the usage. We also used the typecheck library to rigorously check the type and reduce the exception cases.

## Build and Publish using Ship

this project build (or attach) sources using ship https://github.com/aergoio/ship

to build and publish all project to local ship repository, run `./scripts/deploy.sh`