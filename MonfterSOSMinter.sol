// SPDX-License-Identifier: MIT
pragma solidity 0.8.8;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface MonfterNFT {
    function safeMint(address) external;
}

contract MonfterSOSMinter is Context, ReentrancyGuard {
    using Counters for Counters.Counter;
    using SafeMath for uint256;

    IERC20 public sosToken;
    MonfterNFT public monfterNft;

    uint256 public MIN_MON_HOLD = 10000000e18;
    uint256 public MAX_FREE_MINT = 721;

    uint256 public sosHolderMint;
    mapping(address => uint256) public mintLog;

    event Mint(address indexed account);

    constructor(IERC20 _sosToken, MonfterNFT _monfterNft) {
        sosToken = _sosToken;
        monfterNft = _monfterNft;
    }

    function beforeMint() internal view {
        require(
            sosToken.balanceOf(_msgSender()) >= MIN_MON_HOLD,
            "invalid token amount"
        );
        require(sosHolderMint.add(1) <= MAX_FREE_MINT, "mint end");
        require(mintLog[_msgSender()] <= 0, "already mint");
    }

    function afterMint() internal {
        sosHolderMint = sosHolderMint.add(1);
        mintLog[_msgSender()] += 1;
    }

    function preMintLeft() public view returns (uint256) {
        return MAX_FREE_MINT.sub(sosHolderMint);
    }

    function freeMint() public nonReentrant {
        beforeMint();

        monfterNft.safeMint(_msgSender());

        afterMint();

        emit Mint(_msgSender());
    }
}
