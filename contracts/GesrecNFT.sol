pragma solidity ^0.8.5;

// Use OpenZeppelin as NFT framework
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.4.0/contracts/token/ERC721/ERC721Full.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.1/contracts/token/ERC721/ERC721.sol";

contract GesrecContentNFT is ERC721 {
    enum Roles {ServiceProvider, Creator, CurrentOwner}

    struct Shareholder {
        uint32 share_millipercent;
        Roles role;
    }

    struct ShareholderArg {
        address id;
        uint32 share_millipercent;
        Roles role;
    }

    struct Content {
        string contentType;
        string title;
        string url;
        string gesrecContentId;
    }

    struct ContentToken {
        Shareholder[] shareholders;
        Content content;
    }

    //STORAGE to store tokens
    ContentToken[] public tokens;

    //STORAGE for originators with address as key
    mapping(address => Shareholder) public originators;

    //STORATGE for content information
    Content public content;

    //Current owner of this token
    Address public currentOwner;

    //Constructor
    constructor(ShareholderArg[] _shareholders, Content _content)
        public
        ERC721Full("GesrecContentNFT", "Content NFT for GESREC service")
    {
        // Require share total to be 100% when distributing
        uint32 shareTotal = 0;
        bool hasServiceProvider = false;

        //add rest of shareholders by converting struct array to mapping
        for (uint256 i = 0; i < _shareholders.length; i++) {
            originators[_shareholders[i].id] = Shareholder(
                _shareholders[i].share_millipercent,
                _shareholders[i].role
            );
            shareTotlal += _shareholders[i].share_millipercent;
            if (
                originators[_shareholders[i].id] == msg.sender &&
                originators[_shareholders[i]].role == Role.ServiceProvider
            ) {
                hasServiceProvider = true;
            }
        }

        // Require one service provider. Most of cases GESREC is the one.
        require(hasServiceProvider);
        // Require provider and creator's share total to be exact 50%
        // Use this service to calculate share_millipercent: https://www.convertunits.com/from/millipercent/to/percent
        // require(shareTotal == 50000);

        //add content information
        content = _content;

        //Initiate Non-Fungible Token
    }

    //publish token with mint function
    function mint() external {
        // uint256 id = tokens.push(Token('name','description')) - 1;
        uint256 id = tokens.push(ContentToken(shareholders, content)) - 1;
        super._mint(msg.sender, id);
    }
}
