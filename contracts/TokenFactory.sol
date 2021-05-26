// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;




import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

library Exclusive {
    struct RoleMembership {
        address member;
    }

    function isMember(RoleMembership storage roleMembership, address memberToCheck) internal view returns (bool) {
        return roleMembership.member == memberToCheck;
    }

    function resetMember(RoleMembership storage roleMembership, address newMember) internal {
        require(newMember != address(0x0), "Cannot set an exclusive role to 0x0");
        roleMembership.member = newMember;
    }

    function getMember(RoleMembership storage roleMembership) internal view returns (address) {
        return roleMembership.member;
    }

    function init(RoleMembership storage roleMembership, address initialMember) internal {
        resetMember(roleMembership, initialMember);
    }
}

library Shared {
    struct RoleMembership {
        mapping(address => bool) members;
    }

    function isMember(RoleMembership storage roleMembership, address memberToCheck) internal view returns (bool) {
        return roleMembership.members[memberToCheck];
    }

    function addMember(RoleMembership storage roleMembership, address memberToAdd) internal {
        require(memberToAdd != address(0x0), "Cannot add 0x0 to a shared role");
        roleMembership.members[memberToAdd] = true;
    }

    function removeMember(RoleMembership storage roleMembership, address memberToRemove) internal {
        roleMembership.members[memberToRemove] = false;
    }

    function init(RoleMembership storage roleMembership, address[] memory initialMembers) internal {
        for (uint256 i = 0; i < initialMembers.length; i++) {
            addMember(roleMembership, initialMembers[i]);
        }
    }
}

/**
 * @title Base class to manage permissions for the derived class.
 */
abstract contract MultiRole {
    using Exclusive for Exclusive.RoleMembership;
    using Shared for Shared.RoleMembership;

    enum RoleType { Invalid, Exclusive, Shared }

    struct Role {
        uint256 managingRole;
        RoleType roleType;
        Exclusive.RoleMembership exclusiveRoleMembership;
        Shared.RoleMembership sharedRoleMembership;
    }

    mapping(uint256 => Role) private roles;

    event ResetExclusiveMember(uint256 indexed roleId, address indexed newMember, address indexed manager);
    event AddedSharedMember(uint256 indexed roleId, address indexed newMember, address indexed manager);
    event RemovedSharedMember(uint256 indexed roleId, address indexed oldMember, address indexed manager);

    /**
     * @notice Reverts unless the caller is a member of the specified roleId.
     */
    modifier onlyRoleHolder(uint256 roleId) {
        require(holdsRole(roleId, msg.sender), "Sender does not hold required role");
        _;
    }

    /**
     * @notice Reverts unless the caller is a member of the manager role for the specified roleId.
     */
    modifier onlyRoleManager(uint256 roleId) {
        require(holdsRole(roles[roleId].managingRole, msg.sender), "Can only be called by a role manager");
        _;
    }

    /**
     * @notice Reverts unless the roleId represents an initialized, exclusive roleId.
     */
    modifier onlyExclusive(uint256 roleId) {
        require(roles[roleId].roleType == RoleType.Exclusive, "Must be called on an initialized Exclusive role");
        _;
    }

    /**
     * @notice Reverts unless the roleId represents an initialized, shared roleId.
     */
    modifier onlyShared(uint256 roleId) {
        require(roles[roleId].roleType == RoleType.Shared, "Must be called on an initialized Shared role");
        _;
    }

    /**
     * @notice Whether `memberToCheck` is a member of roleId.
     * @dev Reverts if roleId does not correspond to an initialized role.
     * @param roleId the Role to check.
     * @param memberToCheck the address to check.
     * @return True if `memberToCheck` is a member of `roleId`.
     */
    function holdsRole(uint256 roleId, address memberToCheck) public view returns (bool) {
        Role storage role = roles[roleId];
        if (role.roleType == RoleType.Exclusive) {
            return role.exclusiveRoleMembership.isMember(memberToCheck);
        } else if (role.roleType == RoleType.Shared) {
            return role.sharedRoleMembership.isMember(memberToCheck);
        }
        revert("Invalid roleId");
    }

    /**
     * @notice Changes the exclusive role holder of `roleId` to `newMember`.
     * @dev Reverts if the caller is not a member of the managing role for `roleId` or if `roleId` is not an
     * initialized, ExclusiveRole.
     * @param roleId the ExclusiveRole membership to modify.
     * @param newMember the new ExclusiveRole member.
     */
    function resetMember(uint256 roleId, address newMember) public onlyExclusive(roleId) onlyRoleManager(roleId) {
        roles[roleId].exclusiveRoleMembership.resetMember(newMember);
        emit ResetExclusiveMember(roleId, newMember, msg.sender);
    }

    /**
     * @notice Gets the current holder of the exclusive role, `roleId`.
     * @dev Reverts if `roleId` does not represent an initialized, exclusive role.
     * @param roleId the ExclusiveRole membership to check.
     * @return the address of the current ExclusiveRole member.
     */
    function getMember(uint256 roleId) public view onlyExclusive(roleId) returns (address) {
        return roles[roleId].exclusiveRoleMembership.getMember();
    }

    /**
     * @notice Adds `newMember` to the shared role, `roleId`.
     * @dev Reverts if `roleId` does not represent an initialized, SharedRole or if the caller is not a member of the
     * managing role for `roleId`.
     * @param roleId the SharedRole membership to modify.
     * @param newMember the new SharedRole member.
     */
    function addMember(uint256 roleId, address newMember) public onlyShared(roleId) onlyRoleManager(roleId) {
        roles[roleId].sharedRoleMembership.addMember(newMember);
        emit AddedSharedMember(roleId, newMember, msg.sender);
    }

    /**
     * @notice Removes `memberToRemove` from the shared role, `roleId`.
     * @dev Reverts if `roleId` does not represent an initialized, SharedRole or if the caller is not a member of the
     * managing role for `roleId`.
     * @param roleId the SharedRole membership to modify.
     * @param memberToRemove the current SharedRole member to remove.
     */
    function removeMember(uint256 roleId, address memberToRemove) public onlyShared(roleId) onlyRoleManager(roleId) {
        roles[roleId].sharedRoleMembership.removeMember(memberToRemove);
        emit RemovedSharedMember(roleId, memberToRemove, msg.sender);
    }

    /**
     * @notice Removes caller from the role, `roleId`.
     * @dev Reverts if the caller is not a member of the role for `roleId` or if `roleId` is not an
     * initialized, SharedRole.
     * @param roleId the SharedRole membership to modify.
     */
    function renounceMembership(uint256 roleId) public onlyShared(roleId) onlyRoleHolder(roleId) {
        roles[roleId].sharedRoleMembership.removeMember(msg.sender);
        emit RemovedSharedMember(roleId, msg.sender, msg.sender);
    }

    /**
     * @notice Reverts if `roleId` is not initialized.
     */
    modifier onlyValidRole(uint256 roleId) {
        require(roles[roleId].roleType != RoleType.Invalid, "Attempted to use an invalid roleId");
        _;
    }

    /**
     * @notice Reverts if `roleId` is initialized.
     */
    modifier onlyInvalidRole(uint256 roleId) {
        require(roles[roleId].roleType == RoleType.Invalid, "Cannot use a pre-existing role");
        _;
    }

    /**
     * @notice Internal method to initialize a shared role, `roleId`, which will be managed by `managingRoleId`.
     * `initialMembers` will be immediately added to the role.
     * @dev Should be called by derived contracts, usually at construction time. Will revert if the role is already
     * initialized.
     */
    function _createSharedRole(
        uint256 roleId,
        uint256 managingRoleId,
        address[] memory initialMembers
    ) internal onlyInvalidRole(roleId) {
        Role storage role = roles[roleId];
        role.roleType = RoleType.Shared;
        role.managingRole = managingRoleId;
        role.sharedRoleMembership.init(initialMembers);
        require(
            roles[managingRoleId].roleType != RoleType.Invalid,
            "Attempted to use an invalid role to manage a shared role"
        );
    }

    /**
     * @notice Internal method to initialize an exclusive role, `roleId`, which will be managed by `managingRoleId`.
     * `initialMember` will be immediately added to the role.
     * @dev Should be called by derived contracts, usually at construction time. Will revert if the role is already
     * initialized.
     */
    function _createExclusiveRole(
        uint256 roleId,
        uint256 managingRoleId,
        address initialMember
    ) internal onlyInvalidRole(roleId) {
        Role storage role = roles[roleId];
        role.roleType = RoleType.Exclusive;
        role.managingRole = managingRoleId;
        role.exclusiveRoleMembership.init(initialMember);
        require(
            roles[managingRoleId].roleType != RoleType.Invalid,
            "Attempted to use an invalid role to manage an exclusive role"
        );
    }
}

/**
 * @title ERC20 interface that includes burn and mint methods.
 */
abstract contract ExpandedIERC20 is IERC20 {
    /**
     * @notice Burns a specific amount of the caller's tokens.
     * @dev Only burns the caller's tokens, so it is safe to leave this method permissionless.
     */
    function burn(uint256 value) external virtual;

    /**
     * @notice Mints tokens and adds them to the balance of the `to` address.
     * @dev This method should be permissioned to only allow designated parties to mint tokens.
     */
    function mint(address to, uint256 value) external virtual returns (bool);

    function addMinter(address account) external virtual;

    function addBurner(address account) external virtual;

    function resetOwner(address account) external virtual;
}

/**
 * @title An ERC20 with permissioned burning and minting. The contract deployer will initially
 * be the owner who is capable of adding new roles.
 */
contract ExpandedERC20 is ExpandedIERC20, ERC20, MultiRole {
    enum Roles {
        // Can set the minter and burner.
        Owner,
        // Addresses that can mint new tokens.
        Minter,
        // Addresses that can burn tokens that address owns.
        Burner
    }

    uint8 _decimals;

    /**
     * @notice Constructs the ExpandedERC20.
     * @param _tokenName The name which describes the new token.
     * @param _tokenSymbol The ticker abbreviation of the name. Ideally < 5 chars.
     * @param _tokenDecimals The number of decimals to define token precision.
     */
    constructor(
        string memory _tokenName,
        string memory _tokenSymbol,
        uint8 _tokenDecimals
    ) ERC20(_tokenName, _tokenSymbol) {
        _decimals = _tokenDecimals;
        _createExclusiveRole(uint256(Roles.Owner), uint256(Roles.Owner), msg.sender);
        _createSharedRole(uint256(Roles.Minter), uint256(Roles.Owner), new address[](0));
        _createSharedRole(uint256(Roles.Burner), uint256(Roles.Owner), new address[](0));
    }

    function decimals() public view virtual override(ERC20) returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Mints `value` tokens to `recipient`, returning true on success.
     * @param recipient address to mint to.
     * @param value amount of tokens to mint.
     * @return True if the mint succeeded, or False.
     */
    function mint(address recipient, uint256 value)
        external
        override
        onlyRoleHolder(uint256(Roles.Minter))
        returns (bool)
    {
        _mint(recipient, value);
        return true;
    }

    /**
     * @dev Burns `value` tokens owned by `msg.sender`.
     * @param value amount of tokens to burn.
     */
    function burn(uint256 value) external override onlyRoleHolder(uint256(Roles.Burner)) {
        _burn(msg.sender, value);
    }

    /**
     * @notice Add Minter role to account.
     * @dev The caller must have the Owner role.
     * @param account The address to which the Minter role is added.
     */
    function addMinter(address account) external virtual override {
        addMember(uint256(Roles.Minter), account);
    }

    /**
     * @notice Add Burner role to account.
     * @dev The caller must have the Owner role.
     * @param account The address to which the Burner role is added.
     */
    function addBurner(address account) external virtual override {
        addMember(uint256(Roles.Burner), account);
    }

    /**
     * @notice Reset Owner role to account.
     * @dev The caller must have the Owner role.
     * @param account The new holder of the Owner role.
     */
    function resetOwner(address account) external virtual override {
        resetMember(uint256(Roles.Owner), account);
    }
}

/**
 * @title A contract that provides modifiers to prevent reentrancy to state-changing and view-only methods. This contract
 * is inspired by https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/ReentrancyGuard.sol
 * and https://github.com/balancer-labs/balancer-core/blob/master/contracts/BPool.sol.
 */
contract Lockable {
    bool private _notEntered;

    constructor() {
        // Storing an initial non-zero value makes deployment a bit more
        // expensive, but in exchange the refund on every call to nonReentrant
        // will be lower in amount. Since refunds are capped to a percetange of
        // the total transaction's gas, it is best to keep them low in cases
        // like this one, to increase the likelihood of the full refund coming
        // into effect.
        _notEntered = true;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _preEntranceCheck();
        _preEntranceSet();
        _;
        _postEntranceReset();
    }

    /**
     * @dev Designed to prevent a view-only method from being re-entered during a call to a `nonReentrant()` state-changing method.
     */
    modifier nonReentrantView() {
        _preEntranceCheck();
        _;
    }

    // Internal methods are used to avoid copying the require statement's bytecode to every `nonReentrant()` method.
    // On entry into a function, `_preEntranceCheck()` should always be called to check if the function is being re-entered.
    // Then, if the function modifies state, it should call `_postEntranceSet()`, perform its logic, and then call `_postEntranceReset()`.
    // View-only methods can simply call `_preEntranceCheck()` to make sure that it is not being re-entered.
    function _preEntranceCheck() internal view {
        // On the first call to nonReentrant, _notEntered will be true
        require(_notEntered, "ReentrancyGuard: reentrant call");
    }

    function _preEntranceSet() internal {
        // Any calls to nonReentrant after this point will fail
        _notEntered = false;
    }

    function _postEntranceReset() internal {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _notEntered = true;
    }
}

/**
 * @title Burnable and mintable ERC20.
 * @dev The contract deployer will initially be the only minter, burner and owner capable of adding new roles.
 */

contract SyntheticToken is ExpandedERC20, Lockable {
    /**
     * @notice Constructs the SyntheticToken.
     * @param tokenName The name which describes the new token.
     * @param tokenSymbol The ticker abbreviation of the name. Ideally < 5 chars.
     * @param tokenDecimals The number of decimals to define token precision.
     */
    constructor(
        string memory tokenName,
        string memory tokenSymbol,
        uint8 tokenDecimals
    ) ExpandedERC20(tokenName, tokenSymbol, tokenDecimals) nonReentrant() {}

    /**
     * @notice Add Minter role to account.
     * @dev The caller must have the Owner role.
     * @param account The address to which the Minter role is added.
     */
    function addMinter(address account) external override nonReentrant() {
        addMember(uint256(Roles.Minter), account);
    }

    /**
     * @notice Remove Minter role from account.
     * @dev The caller must have the Owner role.
     * @param account The address from which the Minter role is removed.
     */
    function removeMinter(address account) external nonReentrant() {
        removeMember(uint256(Roles.Minter), account);
    }

    /**
     * @notice Add Burner role to account.
     * @dev The caller must have the Owner role.
     * @param account The address to which the Burner role is added.
     */
    function addBurner(address account) external override nonReentrant() {
        addMember(uint256(Roles.Burner), account);
    }

    /**
     * @notice Removes Burner role from account.
     * @dev The caller must have the Owner role.
     * @param account The address from which the Burner role is removed.
     */
    function removeBurner(address account) external nonReentrant() {
        removeMember(uint256(Roles.Burner), account);
    }

    /**
     * @notice Reset Owner role to account.
     * @dev The caller must have the Owner role.
     * @param account The new holder of the Owner role.
     */
    function resetOwner(address account) external override nonReentrant() {
        resetMember(uint256(Roles.Owner), account);
    }

    /**
     * @notice Checks if a given account holds the Minter role.
     * @param account The address which is checked for the Minter role.
     * @return bool True if the provided account is a Minter.
     */
    function isMinter(address account) public view nonReentrantView() returns (bool) {
        return holdsRole(uint256(Roles.Minter), account);
    }

    /**
     * @notice Checks if a given account holds the Burner role.
     * @param account The address which is checked for the Burner role.
     * @return bool True if the provided account is a Burner.
     */
    function isBurner(address account) public view nonReentrantView() returns (bool) {
        return holdsRole(uint256(Roles.Burner), account);
    }
}

/**
 * @title Factory for creating new mintable and burnable tokens.
 */

contract TokenFactory is Lockable {
    /**
     * @notice Create a new token and return it to the caller.
     * @dev The caller will become the only minter and burner and the new owner capable of assigning the roles.
     * @param tokenName used to describe the new token.
     * @param tokenSymbol short ticker abbreviation of the name. Ideally < 5 chars.
     * @param tokenDecimals used to define the precision used in the token's numerical representation.
     * @return newToken an instance of the newly created token interface.
     */
    function createToken(
        string calldata tokenName,
        string calldata tokenSymbol,
        uint8 tokenDecimals
    ) external nonReentrant() returns (ExpandedIERC20 newToken) {
        SyntheticToken mintableToken = new SyntheticToken(tokenName, tokenSymbol, tokenDecimals);
        mintableToken.addMinter(msg.sender);
        mintableToken.addBurner(msg.sender);
        mintableToken.resetOwner(msg.sender);
        newToken = ExpandedIERC20(address(mintableToken));
    }
}