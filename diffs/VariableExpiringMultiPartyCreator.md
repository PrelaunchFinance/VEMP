```diff --git a/./emp/ExpiringMultiPartyCreator.sol b/./variable-expiring-multiparty/contracts/VariableExpiringMultiPartyCreator.sol
index 4ecb267..8d96ab6 100644
--- a/./emp/ExpiringMultiPartyCreator.sol
+++ b/./variable-expiring-multiparty/contracts/VariableExpiringMultiPartyCreator.sol
@@ -1,18 +1,19 @@
 // SPDX-License-Identifier: AGPL-3.0-only
 pragma solidity ^0.8.0;
-
-import "../../common/interfaces/ExpandedIERC20.sol";
-import "../../common/interfaces/IERC20Standard.sol";
-import "../../oracle/implementation/ContractCreator.sol";
-import "../../common/implementation/Testable.sol";
-import "../../common/implementation/AddressWhitelist.sol";
-import "../../common/implementation/Lockable.sol";
-import "../common/TokenFactory.sol";
-import "../common/SyntheticToken.sol";
-import "./ExpiringMultiPartyLib.sol";
+pragma abicoder v2;
+
+import "@uma/core/contracts/common/interfaces/ExpandedIERC20.sol";
+import "@uma/core/contracts/common/interfaces/IERC20Standard.sol";
+import "@uma/core/contracts/oracle/implementation/ContractCreator.sol";
+import "@uma/core/contracts/common/implementation/Testable.sol";
+import "@uma/core/contracts/common/implementation/AddressWhitelist.sol";
+import "@uma/core/contracts/common/implementation/Lockable.sol";
+import "@uma/core/contracts/financial-templates/common/TokenFactory.sol";
+import "@uma/core/contracts/financial-templates/common/SyntheticToken.sol";
+import "./VariableExpiringMultiPartyLib.sol";
 
 /**
- * @title Expiring Multi Party Contract creator.
+ * @title Variable Expiring Multi Party Contract creator.
  * @notice Factory contract to create and register new instances of expiring multiparty contracts.
  * Responsible for constraining the parameters used to construct a new EMP. This creator contains a number of constraints
  * that are applied to newly created expiring multi party contract. These constraints can evolve over time and are
@@ -21,7 +22,7 @@ import "./ExpiringMultiPartyLib.sol";
  * to be the only way to create valid financial contracts that are registered with the DVM (via _registerContract),
   we can enforce deployment configurations here.
  */
-contract ExpiringMultiPartyCreator is ContractCreator, Testable, Lockable {
+contract VariableExpiringMultiPartyCreator is ContractCreator, Testable, Lockable {
     using FixedPoint for FixedPoint.Unsigned;
 
     /****************************************
@@ -42,6 +43,7 @@ contract ExpiringMultiPartyCreator is ContractCreator, Testable, Lockable {
         uint256 withdrawalLiveness;
         uint256 liquidationLiveness;
         address financialProductLibraryAddress;
+        address externalVariableExpirationDAOAddress;
     }
     // Address of TokenFactory used to create a new synthetic token.
     address public tokenFactoryAddress;
@@ -77,7 +79,7 @@ contract ExpiringMultiPartyCreator is ContractCreator, Testable, Lockable {
         // applied to the newly created synthetic token.
         uint8 syntheticDecimals = _getSyntheticDecimals(params.collateralAddress);
         ExpandedIERC20 tokenCurrency = tf.createToken(params.syntheticName, params.syntheticSymbol, syntheticDecimals);
-        address derivative = ExpiringMultiPartyLib.deploy(_convertParams(params, tokenCurrency));
+        address derivative = VariableExpiringMultiPartyLib.deploy(_convertParams(params, tokenCurrency));
 
         // Give permissions to new derivative contract and then hand over ownership.
         tokenCurrency.addMinter(derivative);
@@ -95,11 +97,11 @@ contract ExpiringMultiPartyCreator is ContractCreator, Testable, Lockable {
      *          PRIVATE FUNCTIONS           *
      ****************************************/
 
-    // Converts createExpiringMultiParty params to ExpiringMultiParty constructor params.
+    // Converts createExpiringMultiParty params to VariableExpiringMultiParty constructor params.
     function _convertParams(Params memory params, ExpandedIERC20 newTokenCurrency)
         private
         view
-        returns (ExpiringMultiParty.ConstructorParams memory constructorParams)
+        returns (VariableExpiringMultiParty.ConstructorParams memory constructorParams)
     {
         // Known from creator deployment.
         constructorParams.finderAddress = finderAddress;
@@ -132,6 +134,7 @@ contract ExpiringMultiPartyCreator is ContractCreator, Testable, Lockable {
         constructorParams.withdrawalLiveness = params.withdrawalLiveness;
         constructorParams.liquidationLiveness = params.liquidationLiveness;
         constructorParams.financialProductLibraryAddress = params.financialProductLibraryAddress;
+        constructorParams.externalVariableExpirationDAOAddress = params.externalVariableExpirationDAOAddress;
     }
 
     // IERC20Standard.decimals() will revert if the collateral contract has not implemented the decimals() method,
```
