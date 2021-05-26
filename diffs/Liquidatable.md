```diff --git a/./emp/Liquidatable.sol b/./variable-expiring-multiparty/contracts/Liquidatable.sol
index 96d95f1..1b51883 100644
--- a/./emp/Liquidatable.sol
+++ b/./variable-expiring-multiparty/contracts/Liquidatable.sol
@@ -1,5 +1,6 @@
 // SPDX-License-Identifier: AGPL-3.0-only
 pragma solidity ^0.8.0;
+pragma abicoder v2;
 
 import "@openzeppelin/contracts/utils/math/SafeMath.sol";
 import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
@@ -7,7 +8,7 @@ import "@openzeppelin/contracts/utils/Address.sol";
 
 import "./PricelessPositionManager.sol";
 
-import "../../common/implementation/FixedPoint.sol";
+import "@uma/core/contracts/common/implementation/FixedPoint.sol";
 
 /**
  * @title Liquidatable
@@ -67,6 +68,7 @@ contract Liquidatable is PricelessPositionManager {
         address finderAddress;
         address timerAddress;
         address financialProductLibraryAddress;
+        address externalVariableExpirationDAOAddress;
         bytes32 priceFeedIdentifier;
         FixedPoint.Unsigned minSponsorTokens;
         // Params specifically for Liquidatable.
@@ -182,7 +184,8 @@ contract Liquidatable is PricelessPositionManager {
             params.priceFeedIdentifier,
             params.minSponsorTokens,
             params.timerAddress,
-            params.financialProductLibraryAddress
+            params.financialProductLibraryAddress,
+            params.externalVariableExpirationDAOAddress
         )
         nonReentrant()
     {
```