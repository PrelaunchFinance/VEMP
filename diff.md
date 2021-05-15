diff --git a/./variable-expiring-multiparty/contracts/.DS_Store b/./variable-expiring-multiparty/contracts/.DS_Store
deleted file mode 100644
index 43c03a7..0000000
Binary files a/./variable-expiring-multiparty/contracts/.DS_Store and /dev/null differ
diff --git a/./variable-expiring-multiparty/contracts/VariableExpiringMultiParty.sol b/./emp/ExpiringMultiParty.sol
similarity index 80%
rename from ./variable-expiring-multiparty/contracts/VariableExpiringMultiParty.sol
rename to ./emp/ExpiringMultiParty.sol
index df285b8..51d472b 100644
       --- a/./variable-expiring-multiparty/contracts/VariableExpiringMultiParty.sol
       +++ b/./emp/ExpiringMultiParty.sol
       @@ -1,6 +1,5 @@
        // SPDX-License-Identifier: AGPL-3.0-only
        pragma solidity ^0.8.0;
       -pragma abicoder v2;

        import "./Liquidatable.sol";

       @@ -8,9 +7,9 @@ import "./Liquidatable.sol";
         * @title Expiring Multi Party.
         * @notice Convenient wrapper for Liquidatable.
         */
       -contract VariableExpiringMultiParty is Liquidatable {
       +contract ExpiringMultiParty is Liquidatable {
            /**
       -     * @notice Constructs the VariableExpiringMultiParty contract.
       +     * @notice Constructs the ExpiringMultiParty contract.
             * @param params struct to define input parameters for construction of Liquidatable. Some params
             * are fed directly into the PricelessPositionManager's constructor within the inheritance tree.
             */
diff --git a/./variable-expiring-multiparty/contracts/VariableExpiringMultiPartyCreator.sol b/./emp/ExpiringMultiPartyCreator.sol
similarity index 84%
rename from ./variable-expiring-multiparty/contracts/VariableExpiringMultiPartyCreator.sol
rename to ./emp/ExpiringMultiPartyCreator.sol
index 8d96ab6..4ecb267 100644
--- a/./variable-expiring-multiparty/contracts/VariableExpiringMultiPartyCreator.sol
+++ b/./emp/ExpiringMultiPartyCreator.sol
@@ -1,19 +1,18 @@
 // SPDX-License-Identifier: AGPL-3.0-only
 pragma solidity ^0.8.0;
-pragma abicoder v2;
-
-import "@uma/core/contracts/common/interfaces/ExpandedIERC20.sol";
-import "@uma/core/contracts/common/interfaces/IERC20Standard.sol";
-import "@uma/core/contracts/oracle/implementation/ContractCreator.sol";
-import "@uma/core/contracts/common/implementation/Testable.sol";
-import "@uma/core/contracts/common/implementation/AddressWhitelist.sol";
-import "@uma/core/contracts/common/implementation/Lockable.sol";
-import "@uma/core/contracts/financial-templates/common/TokenFactory.sol";
-import "@uma/core/contracts/financial-templates/common/SyntheticToken.sol";
-import "./VariableExpiringMultiPartyLib.sol";
+
+import "../../common/interfaces/ExpandedIERC20.sol";
+import "../../common/interfaces/IERC20Standard.sol";
+import "../../oracle/implementation/ContractCreator.sol";
+import "../../common/implementation/Testable.sol";
+import "../../common/implementation/AddressWhitelist.sol";
+import "../../common/implementation/Lockable.sol";
+import "../common/TokenFactory.sol";
+import "../common/SyntheticToken.sol";
+import "./ExpiringMultiPartyLib.sol";
 
 /**
- * @title Variable Expiring Multi Party Contract creator.
+ * @title Expiring Multi Party Contract creator.
  * @notice Factory contract to create and register new instances of expiring multiparty contracts.
  * Responsible for constraining the parameters used to construct a new EMP. This creator contains a number of constraints
  * that are applied to newly created expiring multi party contract. These constraints can evolve over time and are
@@ -22,7 +21,7 @@ import "./VariableExpiringMultiPartyLib.sol";
  * to be the only way to create valid financial contracts that are registered with the DVM (via _registerContract),
   we can enforce deployment configurations here.
  */
-contract VariableExpiringMultiPartyCreator is ContractCreator, Testable, Lockable {
+contract ExpiringMultiPartyCreator is ContractCreator, Testable, Lockable {
     using FixedPoint for FixedPoint.Unsigned;
 
     /****************************************
@@ -43,7 +42,6 @@ contract VariableExpiringMultiPartyCreator is ContractCreator, Testable, Lockabl
         uint256 withdrawalLiveness;
         uint256 liquidationLiveness;
         address financialProductLibraryAddress;
-        address externalVariableExpirationDAOAddress;
     }
     // Address of TokenFactory used to create a new synthetic token.
     address public tokenFactoryAddress;
@@ -79,7 +77,7 @@ contract VariableExpiringMultiPartyCreator is ContractCreator, Testable, Lockabl
         // applied to the newly created synthetic token.
         uint8 syntheticDecimals = _getSyntheticDecimals(params.collateralAddress);
         ExpandedIERC20 tokenCurrency = tf.createToken(params.syntheticName, params.syntheticSymbol, syntheticDecimals);
-        address derivative = VariableExpiringMultiPartyLib.deploy(_convertParams(params, tokenCurrency));
+        address derivative = ExpiringMultiPartyLib.deploy(_convertParams(params, tokenCurrency));
 
         // Give permissions to new derivative contract and then hand over ownership.
         tokenCurrency.addMinter(derivative);
@@ -97,11 +95,11 @@ contract VariableExpiringMultiPartyCreator is ContractCreator, Testable, Lockabl
      *          PRIVATE FUNCTIONS           *
      ****************************************/
 
-    // Converts createExpiringMultiParty params to VariableExpiringMultiParty constructor params.
+    // Converts createExpiringMultiParty params to ExpiringMultiParty constructor params.
     function _convertParams(Params memory params, ExpandedIERC20 newTokenCurrency)
         private
         view
-        returns (VariableExpiringMultiParty.ConstructorParams memory constructorParams)
+        returns (ExpiringMultiParty.ConstructorParams memory constructorParams)
     {
         // Known from creator deployment.
         constructorParams.finderAddress = finderAddress;
@@ -134,7 +132,6 @@ contract VariableExpiringMultiPartyCreator is ContractCreator, Testable, Lockabl
         constructorParams.withdrawalLiveness = params.withdrawalLiveness;
         constructorParams.liquidationLiveness = params.liquidationLiveness;
         constructorParams.financialProductLibraryAddress = params.financialProductLibraryAddress;
-        constructorParams.externalVariableExpirationDAOAddress = params.externalVariableExpirationDAOAddress;
     }
 
     // IERC20Standard.decimals() will revert if the collateral contract has not implemented the decimals() method,
diff --git a/./emp/ExpiringMultiPartyLib.sol b/./emp/ExpiringMultiPartyLib.sol
new file mode 100644
index 0000000..9ad551f
--- /dev/null
+++ b/./emp/ExpiringMultiPartyLib.sol
@@ -0,0 +1,22 @@
+// SPDX-License-Identifier: AGPL-3.0-only
+pragma solidity ^0.8.0;
+
+import "./ExpiringMultiParty.sol";
+
+/**
+ * @title Provides convenient Expiring Multi Party contract utilities.
+ * @dev Using this library to deploy EMP's allows calling contracts to avoid importing the full EMP bytecode.
+ */
+library ExpiringMultiPartyLib {
+    /**
+     * @notice Returns address of new EMP deployed with given `params` configuration.
+     * @dev Caller will need to register new EMP with the Registry to begin requesting prices. Caller is also
+     * responsible for enforcing constraints on `params`.
+     * @param params is a `ConstructorParams` object from ExpiringMultiParty.
+     * @return address of the deployed ExpiringMultiParty contract
+     */
+    function deploy(ExpiringMultiParty.ConstructorParams memory params) public returns (address) {
+        ExpiringMultiParty derivative = new ExpiringMultiParty(params);
+        return address(derivative);
+    }
+}
diff --git a/./variable-expiring-multiparty/contracts/Liquidatable.sol b/./emp/Liquidatable.sol
index 1b51883..96d95f1 100644
--- a/./variable-expiring-multiparty/contracts/Liquidatable.sol
+++ b/./emp/Liquidatable.sol
@@ -1,6 +1,5 @@
 // SPDX-License-Identifier: AGPL-3.0-only
 pragma solidity ^0.8.0;
-pragma abicoder v2;
 
 import "@openzeppelin/contracts/utils/math/SafeMath.sol";
 import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
@@ -8,7 +7,7 @@ import "@openzeppelin/contracts/utils/Address.sol";
 
 import "./PricelessPositionManager.sol";
 
-import "@uma/core/contracts/common/implementation/FixedPoint.sol";
+import "../../common/implementation/FixedPoint.sol";
 
 /**
  * @title Liquidatable
@@ -68,7 +67,6 @@ contract Liquidatable is PricelessPositionManager {
         address finderAddress;
         address timerAddress;
         address financialProductLibraryAddress;
-        address externalVariableExpirationDAOAddress;
         bytes32 priceFeedIdentifier;
         FixedPoint.Unsigned minSponsorTokens;
         // Params specifically for Liquidatable.
@@ -184,8 +182,7 @@ contract Liquidatable is PricelessPositionManager {
             params.priceFeedIdentifier,
             params.minSponsorTokens,
             params.timerAddress,
-            params.financialProductLibraryAddress,
-            params.externalVariableExpirationDAOAddress
+            params.financialProductLibraryAddress
         )
         nonReentrant()
     {
diff --git a/./variable-expiring-multiparty/contracts/Migrations.sol b/./variable-expiring-multiparty/contracts/Migrations.sol
deleted file mode 100644
index 9aac975..0000000
--- a/./variable-expiring-multiparty/contracts/Migrations.sol
+++ /dev/null
@@ -1,19 +0,0 @@
-// SPDX-License-Identifier: MIT
-pragma solidity >=0.4.22 <0.9.0;
-
-contract Migrations {
-  address public owner = msg.sender;
-  uint public last_completed_migration;
-
-  modifier restricted() {
-    require(
-      msg.sender == owner,
-      "This function is restricted to the contract's owner"
-    );
-    _;
-  }
-
-  function setCompleted(uint completed) public restricted {
-    last_completed_migration = completed;
-  }
-}
diff --git a/./variable-expiring-multiparty/contracts/PricelessPositionManager.sol b/./emp/PricelessPositionManager.sol
index 5b17ee8..2e3b0f4 100644
--- a/./variable-expiring-multiparty/contracts/PricelessPositionManager.sol
+++ b/./emp/PricelessPositionManager.sol
@@ -1,23 +1,22 @@
 // SPDX-License-Identifier: AGPL-3.0-only
 pragma solidity ^0.8.0;
-pragma abicoder v2;
 
 import "@openzeppelin/contracts/utils/math/SafeMath.sol";
 import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
 import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
 import "@openzeppelin/contracts/utils/Address.sol";
 
-import "@uma/core/contracts/common/implementation/FixedPoint.sol";
-import "@uma/core/contracts/common/interfaces/ExpandedIERC20.sol";
-import "@uma/core/contracts/common/interfaces/IERC20Standard.sol";
+import "../../common/implementation/FixedPoint.sol";
+import "../../common/interfaces/ExpandedIERC20.sol";
+import "../../common/interfaces/IERC20Standard.sol";
 
-import "@uma/core/contracts/oracle/interfaces/OracleInterface.sol";
-import "@uma/core/contracts/oracle/interfaces/OptimisticOracleInterface.sol";
-import "@uma/core/contracts/oracle/interfaces/IdentifierWhitelistInterface.sol";
-import "@uma/core/contracts/oracle/implementation/Constants.sol";
+import "../../oracle/interfaces/OracleInterface.sol";
+import "../../oracle/interfaces/OptimisticOracleInterface.sol";
+import "../../oracle/interfaces/IdentifierWhitelistInterface.sol";
+import "../../oracle/implementation/Constants.sol";
 
-import "@uma/core/contracts/financial-templates/common/FeePayer.sol";
-import "@uma/core/contracts/financial-templates/common/financial-product-libraries/FinancialProductLibrary.sol";
+import "../common/FeePayer.sol";
+import "../common/financial-product-libraries/FinancialProductLibrary.sol";
 
 /**
  * @title Financial contract with priceless position management.
@@ -72,8 +71,6 @@ contract PricelessPositionManager is FeePayer {
     bytes32 public priceIdentifier;
     // Time that this contract expires. Should not change post-construction unless an emergency shutdown occurs.
     uint256 public expirationTimestamp;
-    // Time that the expiration DAO last changed
-    uint256 public updateTimestamp;
     // Time that has to elapse for a withdrawal request to be considered passed, if no liquidations occur.
     // !!Note: The lower the withdrawal liveness value, the more risk incurred by the contract.
     //       Extremely low liveness values increase the chance that opportunistic invalid withdrawal requests
@@ -91,9 +88,6 @@ contract PricelessPositionManager is FeePayer {
     // the functionality of the EMP to support a wider range of financial products.
     FinancialProductLibrary public financialProductLibrary;
 
-    // address for the DAO which will have authority to expire the contract
-    address externalVariableExpirationDAOAddress;
-
     /****************************************
      *                EVENTS                *
      ****************************************/
@@ -118,8 +112,6 @@ contract PricelessPositionManager is FeePayer {
         uint256 indexed tokensBurned
     );
     event EmergencyShutdown(address indexed caller, uint256 originalExpirationTimestamp, uint256 shutdownTimestamp);
-    event VariableExpiration(address indexed caller, uint256 originalExpirationTimestamp, uint256 shutdownTimestamp);
-    event EmergencyUpdateDAOAddress(address indexed previousAddress, address indexed newAddress, uint256 updateTimestamp);
 
     /****************************************
      *               MODIFIERS              *
@@ -166,7 +158,7 @@ contract PricelessPositionManager is FeePayer {
      * @param _tokenAddress ERC20 token used as synthetic token.
      * @param _finderAddress UMA protocol Finder used to discover other protocol contracts.
      * @param _priceIdentifier registered in the DVM for the synthetic.
-     * @param _minSponsorTokens minimum amount of collateral that must exist at any time in a position.
+     * @param _minSponsorTokens minimum number of tokens that must exist at any time in a position.
      * @param _timerAddress Contract that stores the current time in a testing environment.
      * Must be set to 0x0 for production environments that use live time.
      * @param _financialProductLibraryAddress Contract providing contract state transformations.
@@ -180,8 +172,7 @@ contract PricelessPositionManager is FeePayer {
         bytes32 _priceIdentifier,
         FixedPoint.Unsigned memory _minSponsorTokens,
         address _timerAddress,
-        address _financialProductLibraryAddress,
-        address _externalVariableExpirationDAOAddress
+        address _financialProductLibraryAddress
     ) FeePayer(_collateralAddress, _finderAddress, _timerAddress) nonReentrant() {
         require(_expirationTimestamp > getCurrentTime());
         require(_getIdentifierWhitelist().isIdentifierSupported(_priceIdentifier));
@@ -191,7 +182,6 @@ contract PricelessPositionManager is FeePayer {
         tokenCurrency = ExpandedIERC20(_tokenAddress);
         minSponsorTokens = _minSponsorTokens;
         priceIdentifier = _priceIdentifier;
-        externalVariableExpirationDAOAddress = _externalVariableExpirationDAOAddress;
 
         // Initialize the financialProductLibrary at the provided address.
         financialProductLibrary = FinancialProductLibrary(_financialProductLibraryAddress);
@@ -625,37 +615,6 @@ contract PricelessPositionManager is FeePayer {
         emit ContractExpired(msg.sender);
     }
 
-    /**
-     * @notice Update DAO address under emergency circumstances
-     * @dev Only the governor or authorized DAO can call this function.
-     * The new DAOAddress will be authorized to expire the contract, and the old address will be deauthorized.
-     */
-    function emergencyUpdateDAOAddress(address DAOAddress) public {
-        require(msg.sender == _getFinancialContractsAdminAddress() || msg.sender == externalVariableExpirationDAOAddress, 'Caller must be the authorized DAO or the UMA governor');
-        updateTimestamp = getCurrentTime();
-        EmergencyUpdateDAOAddress(externalVariableExpirationDAOAddress, DAOAddress, updateTimestamp);
-        externalVariableExpirationDAOAddress = DAOAddress;
-    }
-
-    /**
-     * @notice Variable contract expiration under pre-defined circumstances.
-     * @dev Only the governor or authorized DAO can call this function.
-     * Upon variable shutdown, the contract settlement time is set to the shutdown time. This enables withdrawal
-     * to occur via the standard `settleExpired` function.
-     */
-    function variableExpiration() external onlyPreExpiration() onlyOpenState() nonReentrant() {
-        require(msg.sender == _getFinancialContractsAdminAddress() || msg.sender == externalVariableExpirationDAOAddress, 'Caller must be the authorized DAO or the UMA governor');
-
-        contractState = ContractState.ExpiredPriceRequested;
-        // Expiration time now becomes the current time (variable shutdown time).
-        // Price received at this time stamp. `settleExpired` can now withdraw at this timestamp.
-        uint256 oldExpirationTimestamp = expirationTimestamp;
-        expirationTimestamp = getCurrentTime();
-        _requestOraclePriceExpiration(expirationTimestamp);
-
-        emit VariableExpiration(msg.sender, oldExpirationTimestamp, expirationTimestamp);
-    }
-
     /**
      * @notice Premature contract settlement under emergency circumstances.
      * @dev Only the governor can call this function as they are permissioned within the `FinancialContractAdmin`.
diff --git a/./variable-expiring-multiparty/contracts/VariableExpiringMultiPartyLib.sol b/./variable-expiring-multiparty/contracts/VariableExpiringMultiPartyLib.sol
deleted file mode 100644
index b120e22..0000000
--- a/./variable-expiring-multiparty/contracts/VariableExpiringMultiPartyLib.sol
+++ /dev/null
@@ -1,23 +0,0 @@
-// SPDX-License-Identifier: AGPL-3.0-only
-pragma solidity ^0.8.0;
-pragma abicoder v2;
-
-import "./VariableExpiringMultiParty.sol";
-
-/**
- * @title Provides convenient Variable Expiring Multi Party contract utilities.
- * @dev Using this library to deploy VEMP's allows calling contracts to avoid importing the full VEMP bytecode.
- */
-library VariableExpiringMultiPartyLib {
-    /**
-     * @notice Returns address of new VEMP deployed with given `params` configuration.
-     * @dev Caller will need to register new VEMP with the Registry to begin requesting prices. Caller is also
-     * responsible for enforcing constraints on `params`.
-     * @param params is a `ConstructorParams` object from VariableExpiringMultiParty.
-     * @return address of the deployed VariableExpiringMultiParty contract
-     */
-    function deploy(VariableExpiringMultiParty.ConstructorParams memory params) public returns (address) {
-        VariableExpiringMultiParty derivative = new VariableExpiringMultiParty(params);
-        return address(derivative);
-    }
-}

