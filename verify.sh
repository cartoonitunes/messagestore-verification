#!/bin/bash
# Verification script for MessageStore (0xd2eccde805e888ae37646544d60185b842ff3d6b)
# Deployed: August 8, 2015 (block 53,573)
# Compiler: soljson v0.1.1+commit.858e7b8 (optimizer ON)

set -e

ADDR="0xd2eccde805e888ae37646544d60185b842ff3d6b"
DEPLOY_TX="0xa13705d6ea905431caeb62c33d9a08ec83cc8557a33316a9612f6cf523dabfcb"
SOLJSON="soljson-v0.1.1+commit.6ff4cd6.js"

echo "=== MessageStore Bytecode Verification ==="
echo "Contract: $ADDR"
echo "Deploy tx: $DEPLOY_TX"
echo "Block: 53,573 (August 8, 2015)"
echo ""

# Download soljson v0.1.1 if needed
if [ ! -f "$SOLJSON" ]; then
    echo "Downloading $SOLJSON..."
    curl -sL "https://binaries.soliditylang.org/bin/$SOLJSON" -o "$SOLJSON"
fi

# Compile with optimizer ON
echo "Compiling with soljson v0.1.1 (optimizer ON)..."
node -e "
const wrapper = require('solc/wrapper');
const soljson = require('./$SOLJSON');
const solc = wrapper(soljson);
const fs = require('fs');
const source = fs.readFileSync('MessageStore.sol', 'utf8');
const result = solc.compile(source, 1);
if (result.errors) { result.errors.forEach(e => console.error(e)); }
const c = result.contracts['MessageStore'];
if (!c) { console.error('Contract not found'); process.exit(1); }
fs.writeFileSync('compiled_creation.hex', c.bytecode);
const rtStart = c.bytecode.indexOf('f300') + 4;
fs.writeFileSync('compiled_runtime.hex', c.bytecode.substring(rtStart));
console.log('Creation: ' + c.bytecode.length/2 + ' bytes');
console.log('Runtime:  ' + (c.bytecode.length - rtStart)/2 + ' bytes');
"

echo ""
echo "Fetching on-chain bytecodes (requires ETHERSCAN_API_KEY env var)..."
API_KEY="${ETHERSCAN_API_KEY:-YourApiKeyToken}"

ONCHAIN_RUNTIME=$(curl -s "https://api.etherscan.io/api?module=proxy&action=eth_getCode&address=$ADDR&apikey=$API_KEY" | python3 -c "import sys,json; print(json.load(sys.stdin)['result'][2:])")
echo "$ONCHAIN_RUNTIME" > onchain_runtime.hex

ONCHAIN_CREATION=$(curl -s "https://api.etherscan.io/api?module=proxy&action=eth_getTransactionByHash&txhash=$DEPLOY_TX&apikey=$API_KEY" | python3 -c "import sys,json; print(json.load(sys.stdin)['result']['input'][2:])")
echo "$ONCHAIN_CREATION" > onchain_creation.hex

echo ""
echo "=== Verification Results ==="

if diff -q compiled_runtime.hex onchain_runtime.hex > /dev/null 2>&1; then
    echo "RUNTIME:  Exact byte-for-byte match"
else
    echo "RUNTIME:  MISMATCH"
    diff compiled_runtime.hex onchain_runtime.hex | head -5
fi

if diff -q compiled_creation.hex onchain_creation.hex > /dev/null 2>&1; then
    echo "CREATION: Exact byte-for-byte match"
else
    echo "CREATION: MISMATCH"
    diff compiled_creation.hex onchain_creation.hex | head -5
fi

echo ""
echo "SHA256 of compiled creation bytecode:"
shasum -a 256 compiled_creation.hex
