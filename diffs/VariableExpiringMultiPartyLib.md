```diff --git a/./emp/ExpiringMultiPartyLib.sol b/./variable-expiring-multiparty/contracts/VariableExpiringMultiPartyLib.sol
index 9ad551f..b120e22 100644
--- a/./emp/ExpiringMultiPartyLib.sol
+++ b/./variable-expiring-multiparty/contracts/VariableExpiringMultiPartyLib.sol
@@ -1,22 +1,23 @@
 // SPDX-License-Identifier: AGPL-3.0-only
 pragma solidity ^0.8.0;
+pragma abicoder v2;
 
-import "./ExpiringMultiParty.sol";
+import "./VariableExpiringMultiParty.sol";
 
 /**
- * @title Provides convenient Expiring Multi Party contract utilities.
- * @dev Using this library to deploy EMP's allows calling contracts to avoid importing the full EMP bytecode.
+ * @title Provides convenient Variable Expiring Multi Party contract utilities.
+ * @dev Using this library to deploy VEMP's allows calling contracts to avoid importing the full VEMP bytecode.
  */
-library ExpiringMultiPartyLib {
+library VariableExpiringMultiPartyLib {
     /**
-     * @notice Returns address of new EMP deployed with given `params` configuration.
-     * @dev Caller will need to register new EMP with the Registry to begin requesting prices. Caller is also
+     * @notice Returns address of new VEMP deployed with given `params` configuration.
+     * @dev Caller will need to register new VEMP with the Registry to begin requesting prices. Caller is also
      * responsible for enforcing constraints on `params`.
-     * @param params is a `ConstructorParams` object from ExpiringMultiParty.
-     * @return address of the deployed ExpiringMultiParty contract
+     * @param params is a `ConstructorParams` object from VariableExpiringMultiParty.
+     * @return address of the deployed VariableExpiringMultiParty contract
      */
-    function deploy(ExpiringMultiParty.ConstructorParams memory params) public returns (address) {
-        ExpiringMultiParty derivative = new ExpiringMultiParty(params);
+    function deploy(VariableExpiringMultiParty.ConstructorParams memory params) public returns (address) {
+        VariableExpiringMultiParty derivative = new VariableExpiringMultiParty(params);
         return address(derivative);
     }
 }
```