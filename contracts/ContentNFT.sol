// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

// Use OpenZeppelin as NFT framework
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.1/contracts/token/ERC721/ERC721.sol";

contract GesrecContentNFT is ERC721 {
    enum Roles {ServiceProvider, Creator, CurrentOwner}

    struct Shareholder {
        address id;
        uint32 share_millipercent;
        Roles role;
    }

    struct Content {
        string contentType;
        string title;
        string uri;
        string gesrecContentId;
    }

    struct ContentToken {
        Shareholder[] shareholders;
        Content content;
    }

    //STORAGE to store tokens
    ContentToken[] public tokens;

    //STORAGE for the current owner of this token
    address public currentOwner;

    //Constructor
    constructor(Shareholder[] memory _shareholders, Content memory _content)
        ERC721("GesrecContentNFT", "Content NFT for GESREC service")
    {
        // Require share total to be 100% when distributing
        uint32 shareTotal = 0;
        uint8 hasServiceProvider = 0;
        uint256 tokenIndex = tokens.length;

        //add rest of shareholders by converting struct array to mapping
        for (uint256 i = 0; i < _shareholders.length; i++) {
            // push one shareholder information to current token
            tokens[tokenIndex].shareholders[i] = Shareholder(
                _shareholders[i].id,
                _shareholders[i].share_millipercent,
                _shareholders[i].role
            );

            // calculate share total
            shareTotal += _shareholders[i].share_millipercent;

            // check if this shareholder is Service Provider because we need one service provier.
            if (
                _shareholders[i].id == msg.sender &&
                _shareholders[i].role == Roles.ServiceProvider
            ) {
                hasServiceProvider++;
            }
        }

        // Require exactly one service provider. Most of cases GESREC is the one.
        require(hasServiceProvider == 1);

        // share total should be less than or equal to 100%
        require(shareTotal <= 100000);

        //add content information to new token
        tokens[tokenIndex].content = _content;
    }

    //publish token with mint function
    function mint() external {
        uint256 id = tokens.length;
        super._mint(msg.sender, id);
    }
}
