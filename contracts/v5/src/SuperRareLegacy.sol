pragma solidity ^0.5.0;

import "openzeppelin-solidity-pixura/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-solidity-pixura/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity-pixura/contracts/math/SafeMath.sol";
import "openzeppelin-solidity-pixura/contracts/token/ERC721/ERC721Full.sol";
import "./ISupeRare.sol";
import "./IERC721Creator.sol";


/**
 * @title SuperRare Legacy Tokens
 * @dev This contract acts the new SuperRare Legacy contract (formerly known as SupeRare).
 * It is used to upgrade SupeRare tokens to make them fully ERC721 compliant.
 *
 */
contract SuperRareLegacy is ERC721Full, IERC721Creator, Ownable {
    using SafeMath for uint256;

    /////////////////////////////////////////////////////////////////////////
    // State Variables
    /////////////////////////////////////////////////////////////////////////

    // Old SuperRare contract to look up token details.
    ISupeRare private oldSuperRare;

    // Mapping from token ID to the pre upgrade token owner.
    mapping(uint256 => address) private _tokenOwnerPreUpgrade;

    /////////////////////////////////////////////////////////////////////////
    // Constructor
    /////////////////////////////////////////////////////////////////////////
    constructor(
        string memory _name,
        string memory _symbol,
        address _oldSuperRare,
        uint256 _lastTokenId
    ) public ERC721Full(_name, _symbol) {
        // Set old SuperRare.
        oldSuperRare = ISupeRare(_oldSuperRare);

        // Mint the legacy tokens.
        for (uint256 i = 1; i <= _lastTokenId; i++) {
            _createLegacyToken(i);
        }
    }

    /////////////////////////////////////////////////////////////////////////
    // Public Methods
    /////////////////////////////////////////////////////////////////////////

    /////////////////////////////////////////////////////////////////////////
    // ownerOf
    /////////////////////////////////////////////////////////////////////////
    /**
     * @dev Returns the owner of the NFT specified by `tokenId`
     * @param _tokenId uint256 token id to get the owner of.
     * @return address of the token owner.
     */
    function ownerOf(uint256 _tokenId) public view returns (address owner) {
        require(false, "will always fail");
        require(
            isUpgraded(_tokenId),
            "SuperRareLegacy: owner query for non-upgraded token"
        );
        return ERC721.ownerOf(_tokenId);
    }

    /////////////////////////////////////////////////////////////////////////
    // preUpgradeOwnerOf
    /////////////////////////////////////////////////////////////////////////
    /**
     * @dev Returns the pre-upgrade token owner of the NFT specified by `tokenId`. This owner will become the owner of the upgrade legacy token. Throws if
     * @param _tokenId uint256 token id to get the pre-upgrade owner of.
     * @return address of the token pre-upgrade owner.
     */
    function preUpgradeOwnerOf(uint256 _tokenId) public view returns (address) {
        address preUpgradeOwner = _tokenOwnerPreUpgrade[_tokenId];
        require(
            preUpgradeOwner != address(0),
            "SuperRareLegacy: pre-upgrade owner query for nonexistent token"
        );
        return _tokenOwnerPreUpgrade[_tokenId];
    }

    /////////////////////////////////////////////////////////////////////////
    // isUpgraded
    /////////////////////////////////////////////////////////////////////////
    /**
     * @dev Returns whether the token has been upgraded.
     * @param _tokenId uint256 token id to get the owner of.
     * @return bool of whether the token has been upgraded.
     */
    function isUpgraded(uint256 _tokenId) public view returns (bool) {
        address ownerOnOldSuperRare = oldSuperRare.ownerOf(_tokenId);
        return address(this) == ownerOnOldSuperRare;
    }

    /////////////////////////////////////////////////////////////////////////
    // refreshPreUpgradeOwnerOf
    /////////////////////////////////////////////////////////////////////////
    /**
     * @dev Refreshes the pre-upgrade token owner. Useful in the event of a non-upgraded token transferring ownership. Throws if token has upgraded or if there is nothing to refresh.
     * @param _tokenId uint256 token id to refresh the pre-upgrade token owner.
     * @return address of the token pre-upgrade owner.
     */
    function refreshPreUpgradeOwnerOf(uint256 _tokenId) public {
        require(
            !isUpgraded(_tokenId),
            "SuperRareLegacy: cannot refresh an upgraded token"
        );
        address ownerOnOldSuperRare = oldSuperRare.ownerOf(_tokenId);
        require(
            ownerOnOldSuperRare != preUpgradeOwnerOf(_tokenId),
            "SuperRareLegacy: cannot refresh when pre-upgrade owners match"
        );
        _tokenOwnerPreUpgrade[_tokenId] = ownerOnOldSuperRare;
    }

    /////////////////////////////////////////////////////////////////////////
    // tokenCreator
    /////////////////////////////////////////////////////////////////////////
    /**
     * @dev Refreshes the pre-upgrade token owner. Useful in the event of a non-upgraded token transferring ownership. Throws if token has upgraded or if there is nothing to refresh.
     * @param _tokenId uint256 token id to refresh the pre-upgrade token owner.
     * @return address of the token pre-upgrade owner.
     */
    function tokenCreator(uint256 _tokenId) public view returns (address) {
        return oldSuperRare.creatorOfToken(_tokenId);
    }

    /////////////////////////////////////////////////////////////////////////
    // Internal Methods
    /////////////////////////////////////////////////////////////////////////

    /////////////////////////////////////////////////////////////////////////
    // _createLegacyToken
    /////////////////////////////////////////////////////////////////////////
    /**
     * @dev Mints a legacy token with the appropriate metadata and owner.
     * @param _tokenId uint256 token id to get the owner of.
     * @return bool of whether the token has been upgraded.
     */
    function _createLegacyToken(uint256 _tokenId) internal {
        address ownerOnOldSuperRare = oldSuperRare.ownerOf(_tokenId);
        string memory tokenURI = oldSuperRare.tokenURI(_tokenId);
        _mintWithNoEvent(ownerOnOldSuperRare, _tokenId);
        _setTokenURI(_tokenId, tokenURI);
        _tokenOwnerPreUpgrade[_tokenId] = ownerOnOldSuperRare;
    }
}
