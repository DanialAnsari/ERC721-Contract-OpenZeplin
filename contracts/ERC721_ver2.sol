pragma solidity ^0.6.2;

import "./IERC721.sol";
import "./Address.sol";
import "./IERC721Reciever.sol";

contract ERC721 is IERC721 {
    using Address for address;

    mapping(uint256 => address) private _token_owner;

    mapping(uint256 => string) private _tokenName;

    mapping(address => uint256) private balance;

    mapping(uint256 => address) private approved;

    mapping(address => mapping(address => bool)) private allApproved;
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    string _name;
    string _symbol;
    uint256 token_count = 0;

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );
    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    function mint(string memory name) public returns (uint256) {
        _token_owner[token_count] = msg.sender;
        _name = name;
        balance[msg.sender] += 1;
        token_count += 1;
        return (token_count - 1);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external override {
        require(
            Address.isContract(to),
            "Address cannot be send to a contract address"
        );
        require(from != address(0), "Cannot sent to zero address");
        require(to != address(0), "Cannot sent to zero address");
        require(
            from == _token_owner[tokenId],
            "From account must be owner of token"
        );
        require(
            msg.sender == approved[tokenId] ||
                msg.sender == _token_owner[tokenId] ||
                allApproved[_token_owner[tokenId]][msg.sender],
            "Only owner or approved addresses can transfer this token"
        );
        balance[_token_owner[tokenId]] -= 1;
        balance[to] += 1;
        _token_owner[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external override {
        require(to != address(0), "Cannot sent to zero address");
        require(from != address(0), "Cannot be sent from zero address");
        require(
            from == _token_owner[tokenId],
            "From account must be owner of token"
        );
        require(
            msg.sender == approved[tokenId] ||
                msg.sender == _token_owner[tokenId] ||
                allApproved[_token_owner[tokenId]][msg.sender],
            "Only owner or approved addresses can transfer this token"
        );
        balance[_token_owner[tokenId]] -= 1;
        balance[to] += 1;
        _token_owner[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function ownerOf(uint256 tokenId)
        external
        override
        view
        returns (address owner)
    {
        return _token_owner[tokenId];
    }

    function balanceOf(address owner) external override view returns (uint256) {
        return balance[owner];
    }

    function approve(address to, uint256 tokenId) external override {
        require(to != address(0), "Cannot Approve zero address");
        require(
            msg.sender == _token_owner[tokenId],
            "Can only be approved by owner"
        );

        require(msg.sender != to, "Cannot approve self");
        approved[tokenId] = to;
        emit Approval(_token_owner[tokenId], to, tokenId);
    }

    function getApproved(uint256 tokenId)
        external
        override
        view
        returns (address)
    {
        return approved[tokenId];
    }

    function setApprovalForAll(address operator, bool _approved)
        external
        override
    {
        require(operator != address(0), "Cannot Approve zero address");
        allApproved[msg.sender][operator] = _approved;
        emit ApprovalForAll(msg.sender, operator, _approved);
    }

    function isApprovedForAll(address owner, address operator)
        external
        override
        view
        returns (bool)
    {
        return allApproved[owner][operator];
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external override {
        require(
            Address.isContract(to),
            "Address cannot be send to a contract address"
        );
        require(from != address(0), "Cannot sent to zero address");
        require(to != address(0), "Cannot sent to zero address");
        require(
            from == _token_owner[tokenId],
            "From account must be owner of token"
        );
        require(
            msg.sender == approved[tokenId] ||
                msg.sender == _token_owner[tokenId] ||
                allApproved[_token_owner[tokenId]][msg.sender],
            "Only owner or approved addresses can transfer this token"
        );
        balance[_token_owner[tokenId]] -= 1;
        balance[to] += 1;
        _token_owner[tokenId] = to;

        emit Transfer(from, to, tokenId);
        require(
            _checkOnERC721Received(from, to, tokenId, data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (!to.isContract()) {
            return true;
        }
        bytes memory returndata = to.functionCall(
            abi.encodeWithSelector(
                IERC721Receiver(to).onERC721Received.selector,
                msg.sender,
                from,
                tokenId,
                _data
            ),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
        bytes4 retval = abi.decode(returndata, (bytes4));
        return (retval == _ERC721_RECEIVED);
    }
}
