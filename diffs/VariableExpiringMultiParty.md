```diff --git a/./emp/ExpiringMultiParty.sol b/./variable-expiring-multiparty/contracts/VariableExpiringMultiParty.sol
index 51d472b..df285b8 100644
--- a/./emp/ExpiringMultiParty.sol
+++ b/./variable-expiring-multiparty/contracts/VariableExpiringMultiParty.sol
@@ -1,5 +1,6 @@
 // SPDX-License-Identifier: AGPL-3.0-only
 pragma solidity ^0.8.0;
+pragma abicoder v2;
 
 import "./Liquidatable.sol";
 
@@ -7,9 +8,9 @@ import "./Liquidatable.sol";
  * @title Expiring Multi Party.
  * @notice Convenient wrapper for Liquidatable.
  */
-contract ExpiringMultiParty is Liquidatable {
+contract VariableExpiringMultiParty is Liquidatable {
     /**
-     * @notice Constructs the ExpiringMultiParty contract.
+     * @notice Constructs the VariableExpiringMultiParty contract.
      * @param params struct to define input parameters for construction of Liquidatable. Some params
      * are fed directly into the PricelessPositionManager's constructor within the inheritance tree.
      */
```