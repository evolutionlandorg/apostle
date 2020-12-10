pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "./interfaces/IItemBar.sol";
import "./ApostleBaseV2.sol";

contract ApostleBaseV3 is ApostleBaseV2 {

    using SafeMath for uint256;
	
	// 0x434f4e54524143545f41504f53544c455f4954454d5f42415200000000000000
	bytes32 public constant CONTRACT_LAND_ITEM_BAR = "CONTRACT_APOSTLE_ITEM_BAR";

	// rate precision
	uint112 public constant RATE_DECIMALS = 10**8;

    function strengthOf(uint256 _tokenId, address _resourceToken, uint256 _landTokenId) public view returns (uint256) {
        uint talents = tokenId2Apostle[_tokenId].talents;
        uint256 strength = IGeneScience(registry.addressOf(CONTRACT_GENE_SCIENCE))
        .getStrength(talents, _resourceToken, _landTokenId);

		address itemBar = registry.addressOf(CONTRACT_LAND_ITEM_BAR);
		uint256 enhanceRate =
			IItemBar(itemBar).enhanceStrengthRateOf(_resourceToken, _tokenId);
		uint256 enhanceStrength = strength.mul(enhanceRate).div(RATE_DECIMALS);
		uint256 totalStrength = strength.add(enhanceStrength);
		return totalStrength;
    }
}
