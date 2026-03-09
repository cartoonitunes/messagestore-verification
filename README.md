# MessageStore Bytecode Verification

**Contract:** [`0xd2eccde805e888ae37646544d60185b842ff3d6b`](https://etherscan.io/address/0xd2eccde805e888ae37646544d60185b842ff3d6b)
**Deployed:** August 8, 2015 (block 53,573) - Day 9 of Ethereum
**Compiler:** soljson v0.1.1+commit.858e7b8 (optimizer ON)
**Deploy tx:** [`0xa13705d6ea905431caeb62c33d9a08ec83cc8557a33316a9612f6cf523dabfcb`](https://etherscan.io/tx/0xa13705d6ea905431caeb62c33d9a08ec83cc8557a33316a9612f6cf523dabfcb)
**Deployer:** [`0x8674c218f0351a62c3ba78c34fd2182a93da94e2`](https://etherscan.io/address/0x8674c218f0351a62c3ba78c34fd2182a93da94e2)

## Verification

Exact byte-for-byte match on both creation and runtime bytecode.

```
Creation: 458 bytes
Runtime:  439 bytes
```

## About

One of the simplest contracts ever deployed on Ethereum. MessageStore stores a single string in public state and exposes one function to update it. The entire contract is 6 lines of Solidity.

It was deployed on August 8, 2015 - Day 9 of Ethereum's existence - by a deployer who published 18 contracts across blocks 52,970 to 55,260 during the same week, clearly experimenting with what Solidity could do in the days immediately following mainnet launch.

The contract has one public state variable (`message`) and one function (`set`). There are no events, no modifiers, no access control, and no constructor logic beyond zero-initialization. This is characteristic of Solidity v0.1.x contracts, where the language was still being defined.

## Source Code

```solidity
contract MessageStore {
    string public message;

    function set(string _message) {
        message = _message;
    }
}
```

## Key Technical Details

- **Compiler:** soljson v0.1.1 (JavaScript-compiled Solidity, the only release format available in August 2015)
- **Optimizer:** ON (required for exact match; optimizer OFF produces different bytecode)
- **ABI:**
  - `0x569b1b04` - `message()` - public getter, returns `string`
  - `0xb8e010de` - `set(string)` - stores the new message
- **Storage layout:** slot 0 contains the dynamic string (length-prefixed per early ABI encoding)

## How to Verify

```bash
./verify.sh
```

Requirements: Node.js, curl, Python 3

Part of [Ethereum History](https://ethereumhistory.com) - a free archive of Ethereum's earliest smart contracts.
