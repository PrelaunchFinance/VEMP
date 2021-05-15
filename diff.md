new file mode 100644
index 0000000..43c03a7
Binary files /dev/null and b/./variable-expiring-multiparty/contracts/.DS_Store differ
diff --git a/./emp/ExpiringMultiPartyLib.sol b/./emp/ExpiringMultiPartyLib.sol
index 9ad551f..0000000
--- a/./emp/ExpiringMultiPartyLib.sol
+++ /dev/null
@@ -1,22 +0,0 @@
-// SPDX-License-Identifier: AGPL-3.0-only
-pragma solidity ^0.8.0;
-import "./ExpiringMultiParty.sol";
-
-/**
- * @title Provides convenient Expiring Multi Party contract utilities.
- * @dev Using this library to deploy EMP's allows calling contracts to avoid importing the full EMP bytecode.
- */
-library ExpiringMultiPartyLib {
-    /**
-     * @notice Returns address of new EMP deployed with given `params` configuration.
-     * @dev Caller will need to register new EMP with the Registry to begin requesting prices. Caller is also
-     * responsible for enforcing constraints on `params`.
-     * @param params is a `ConstructorParams` object from ExpiringMultiParty.
-     * @return address of the deployed ExpiringMultiParty contract
-     */
-    function deploy(ExpiringMultiParty.ConstructorParams memory params) public returns (address) {
-        ExpiringMultiParty derivative = new ExpiringMultiParty(params);
-        return address(derivative);
-    }
-}
diff --git a/./emp/Liquidatable.sol b/./variable-expiring-multiparty/contracts/Liquidatable.sol
index 96d95f1..1b51883 100644
--- a/./emp/Liquidatable.sol
+++ b/./variable-expiring-multiparty/contracts/Liquidatable.sol
@@ -1,5 +1,6 @@
+pragma abicoder v2;
@@ -7,7 +8,7 @@ import "@openzeppelin/contracts/utils/Address.sol";
-import "../../common/implementation/FixedPoint.sol";
+import "@uma/core/contracts/common/implementation/FixedPoint.sol";
@@ -67,6 +68,7 @@ contract Liquidatable is PricelessPositionManager {
+        address externalVariableExpirationDAOAddress;
@@ -182,7 +184,8 @@ contract Liquidatable is PricelessPositionManager {
-            params.financialProductLibraryAddress
+            params.financialProductLibraryAddress,
+            params.externalVariableExpirationDAOAddress