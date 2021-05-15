diff --git a/./emp/PricelessPositionManager.sol b/./variable-expiring-multiparty/contracts/PricelessPositionManager.sol
index 2e3b0f4..5b17ee8 100644
--- a/./emp/PricelessPositionManager.sol
+++ b/./variable-expiring-multiparty/contracts/PricelessPositionManager.sol
@@ -1,22 +1,23 @@
 // SPDX-License-Identifier: AGPL-3.0-only
 pragma solidity ^0.8.0;
+pragma abicoder v2;
 
 import "@openzeppelin/contracts/utils/math/SafeMath.sol";
 import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
 import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
 import "@openzeppelin/contracts/utils/Address.sol";
 
-import "../../common/implementation/FixedPoint.sol";
-import "../../common/interfaces/ExpandedIERC20.sol";
-import "../../common/interfaces/IERC20Standard.sol";
+import "@uma/core/contracts/common/implementation/FixedPoint.sol";
+import "@uma/core/contracts/common/interfaces/ExpandedIERC20.sol";
+import "@uma/core/contracts/common/interfaces/IERC20Standard.sol";
 
-import "../../oracle/interfaces/OracleInterface.sol";
-import "../../oracle/interfaces/OptimisticOracleInterface.sol";
-import "../../oracle/interfaces/IdentifierWhitelistInterface.sol";
-import "../../oracle/implementation/Constants.sol";
+import "@uma/core/contracts/oracle/interfaces/OracleInterface.sol";
+import "@uma/core/contracts/oracle/interfaces/OptimisticOracleInterface.sol";
+import "@uma/core/contracts/oracle/interfaces/IdentifierWhitelistInterface.sol";
+import "@uma/core/contracts/oracle/implementation/Constants.sol";
 
-import "../common/FeePayer.sol";
-import "../common/financial-product-libraries/FinancialProductLibrary.sol";
+import "@uma/core/contracts/financial-templates/common/FeePayer.sol";
+import "@uma/core/contracts/financial-templates/common/financial-product-libraries/FinancialProductLibrary.sol";
 
 /**
  * @title Financial contract with priceless position management.
@@ -71,6 +72,8 @@ contract PricelessPositionManager is FeePayer {
     bytes32 public priceIdentifier;
     // Time that this contract expires. Should not change post-construction unless an emergency shutdown occurs.
     uint256 public expirationTimestamp;
+    // Time that the expiration DAO last changed
+    uint256 public updateTimestamp;
     // Time that has to elapse for a withdrawal request to be considered passed, if no liquidations occur.
     // !!Note: The lower the withdrawal liveness value, the more risk incurred by the contract.
     //       Extremely low liveness values increase the chance that opportunistic invalid withdrawal requests
@@ -88,6 +91,9 @@ contract PricelessPositionManager is FeePayer {
     // the functionality of the EMP to support a wider range of financial products.
     FinancialProductLibrary public financialProductLibrary;
 
+    // address for the DAO which will have authority to expire the contract
+    address externalVariableExpirationDAOAddress;
+
     /****************************************
      *                EVENTS                *
      ****************************************/
@@ -112,6 +118,8 @@ contract PricelessPositionManager is FeePayer {
         uint256 indexed tokensBurned
     );
     event EmergencyShutdown(address indexed caller, uint256 originalExpirationTimestamp, uint256 shutdownTimestamp);
+    event VariableExpiration(address indexed caller, uint256 originalExpirationTimestamp, uint256 shutdownTimestamp);
+    event EmergencyUpdateDAOAddress(address indexed previousAddress, address indexed newAddress, uint256 updateTimestamp);
 
     /****************************************
      *               MODIFIERS              *
@@ -158,7 +166,7 @@ contract PricelessPositionManager is FeePayer {
      * @param _tokenAddress ERC20 token used as synthetic token.
      * @param _finderAddress UMA protocol Finder used to discover other protocol contracts.
      * @param _priceIdentifier registered in the DVM for the synthetic.
-     * @param _minSponsorTokens minimum number of tokens that must exist at any time in a position.
+     * @param _minSponsorTokens minimum amount of collateral that must exist at any time in a position.
      * @param _timerAddress Contract that stores the current time in a testing environment.
      * Must be set to 0x0 for production environments that use live time.
      * @param _financialProductLibraryAddress Contract providing contract state transformations.
@@ -172,7 +180,8 @@ contract PricelessPositionManager is FeePayer {
         bytes32 _priceIdentifier,
         FixedPoint.Unsigned memory _minSponsorTokens,
         address _timerAddress,
-        address _financialProductLibraryAddress
+        address _financialProductLibraryAddress,
+        address _externalVariableExpirationDAOAddress
     ) FeePayer(_collateralAddress, _finderAddress, _timerAddress) nonReentrant() {
         require(_expirationTimestamp > getCurrentTime());
         require(_getIdentifierWhitelist().isIdentifierSupported(_priceIdentifier));
@@ -182,6 +191,7 @@ contract PricelessPositionManager is FeePayer {
         tokenCurrency = ExpandedIERC20(_tokenAddress);
         minSponsorTokens = _minSponsorTokens;
         priceIdentifier = _priceIdentifier;
+        externalVariableExpirationDAOAddress = _externalVariableExpirationDAOAddress;
 
         // Initialize the financialProductLibrary at the provided address.
         financialProductLibrary = FinancialProductLibrary(_financialProductLibraryAddress);
@@ -615,6 +625,37 @@ contract PricelessPositionManager is FeePayer {
         emit ContractExpired(msg.sender);
     }
 
+    /**
+     * @notice Update DAO address under emergency circumstances
+     * @dev Only the governor or authorized DAO can call this function.
+     * The new DAOAddress will be authorized to expire the contract, and the old address will be deauthorized.
+     */
+    function emergencyUpdateDAOAddress(address DAOAddress) public {
+        require(msg.sender == _getFinancialContractsAdminAddress() || msg.sender == externalVariableExpirationDAOAddress, 'Caller must be the authorized DAO or the UMA governor');
+        updateTimestamp = getCurrentTime();
+        EmergencyUpdateDAOAddress(externalVariableExpirationDAOAddress, DAOAddress, updateTimestamp);
+        externalVariableExpirationDAOAddress = DAOAddress;
+    }
+
+    /**
+     * @notice Variable contract expiration under pre-defined circumstances.
+     * @dev Only the governor or authorized DAO can call this function.
+     * Upon variable shutdown, the contract settlement time is set to the shutdown time. This enables withdrawal
+     * to occur via the standard `settleExpired` function.
+     */
+    function variableExpiration() external onlyPreExpiration() onlyOpenState() nonReentrant() {
+        require(msg.sender == _getFinancialContractsAdminAddress() || msg.sender == externalVariableExpirationDAOAddress, 'Caller must be the authorized DAO or the UMA governor');
+
+        contractState = ContractState.ExpiredPriceRequested;
+        // Expiration time now becomes the current time (variable shutdown time).
+        // Price received at this time stamp. `settleExpired` can now withdraw at this timestamp.
+        uint256 oldExpirationTimestamp = expirationTimestamp;
+        expirationTimestamp = getCurrentTime();
+        _requestOraclePriceExpiration(expirationTimestamp);
+
+        emit VariableExpiration(msg.sender, oldExpirationTimestamp, expirationTimestamp);
+    }
+
     /**
      * @notice Premature contract settlement under emergency circumstances.
      * @dev Only the governor can call this function as they are permissioned within the `FinancialContractAdmin`.
