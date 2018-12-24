# Aergo Contract Example
Blocko is blockchain specialist, providing sample codes for Aergo's smart contract development.

## Libraries
* safemath: It is a library used to prevent overflow, divide-by-zero, etc...
* address: It is an utility library to verify addresses used in aergo.
* object: Lua does not provide classes. This is a library that helps you write reusable code using lua tables.

## Smart Contracts
* helloworld: It is a very basic contract. You can learn how to use set and get.
* fixedtoken: This is an example of a token contract with a fixed amount of issuance.
* exchange: It is a simple token <-> aergo exchange contract.
* crowdsale: Using the object library, we provide a reusable crowdsale contract.


## Build and Publish using Ship
this project build (or attach) sources using ship https://github.com/aergoio/ship

to build and publish all project to local ship repository, run `./scripts/deploy.sh`