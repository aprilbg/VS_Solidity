// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ERC721TokenReceiver {
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes4 _data) external returns(bytes4);
}

interface IKIP17Enumerable {
    function tokenOfOwnerByIndex(address owner, uint256 index) external returns(uint256 tokenId);
}

contract BildNFT {
    mapping (uint256 => address) tokenOwner;
    mapping (address => uint256) ownedTokenCount;
    mapping (address=>mapping(address => bool)) operatorApprovals;
    mapping(uint256 => address) tokenApprovals;
    mapping(address => uint256[])_ownedTokens;
    mapping(uint256 => uint256) _ownedTokensIndex;

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    string private _name = "made";
    string private _symbol = "MADE";
    uint256[] public _allTokens;

    function name() public view returns (string memory){
        return _name;
    }

    function symbol() public view returns (string memory){
        return _symbol;
    }

    function totalSupply() public view returns (uint256) {
        return _allTokens.length;
    }

    function mint(address _to, uint _tokenId) public {
        require(_to != address(0));
        require(!_exists(_tokenId));
        tokenOwner[_tokenId] = _to;
        ownedTokenCount[_to] += 1;
        emit Transfer(address(0), _to, _tokenId);
        _addTokenToOwnerEnumeration(_to, _tokenId);
        _ownedTokensIndex[_tokenId] = _allTokens.length;
        _allTokens.push(_tokenId);
    }

    function tokenByIndex(uint256 index) public view returns (uint256) {
        require(index < totalSupply());
        return _allTokens[index];
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256) {
        require(index < balanceOf(owner));
        return _ownedTokens[owner][index];
    }

    function balanceOf(address _owner) public view returns (uint256) {
        require(_owner != address(0));
        return ownedTokenCount[_owner];   
    }

    function ownerOf(uint256 _tokenId) public view returns (address){
        address owner =  tokenOwner[_tokenId];
        require(owner != address(0));
        return owner;
    }

    function _exists(uint256 tokenId) public view returns (bool) {
        address owner = tokenOwner[tokenId];
        return owner != address(0);
    }

    function _tokensOfOwner(address owner) public view returns (uint256[] memory) {
        return _ownedTokens[owner];
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) internal{
        address owner = ownerOf(_tokenId);
        require(_from == owner || _from == getApproved(_tokenId));
        require(_from != address(0) && _to != address(0));
        require(_from != _from);

        ownedTokenCount[_from] -= 1;
        ownedTokenCount[_to] += 1;
        tokenOwner[_tokenId] = _to;
        emit Transfer(_from, _to, _tokenId);
        _removeTokenFromOwnerEnumeration(_from, _tokenId);
        _addTokenToOwnerEnumeration(_to, _tokenId);
    }

    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        _ownedTokensIndex[tokenId] = _ownedTokens[to].length;
        _ownedTokens[to].push(tokenId);
    }

    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private{
        uint256 lastTokenIndex = _ownedTokens[from].length - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        if (tokenIndex != lastTokenIndex){
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId;
            _ownedTokensIndex[lastTokenId] = tokenIndex;
        }
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    function safeTransferFrom(address _from, address  _to, uint256 _tokenId) public {
        transferFrom(_from, _to, _tokenId);

        if (isContract(_to)){
            bytes4 returnValue = ERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, '');
            require(returnValue == 0x150b7a02);
        }
    }

    function isContract(address _addr) private view returns (bool) {
        uint256 size;
        assembly {size:= extcodesize(_addr)}
        return size > 0;
    }

    function approve(address _approved, uint256 _tokenId) public {
        address owner = ownerOf(_tokenId);
        require(_approved != owner);
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender));
        tokenApprovals[_tokenId] = _approved;
        emit Approval(owner, _approved, _tokenId);
    }

    function getApproved(uint256 _tokenId) public view returns (address) {
        require(_exists(_tokenId));
        return tokenApprovals[_tokenId];
    }

    function setApprovalForAll(address _operator,bool  _approved) public {
        require(msg.sender != _operator);
        operatorApprovals[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function isApprovedForAll(address _owner,address  _operator) public view returns (bool) {
        return operatorApprovals[_owner][_operator];
    }
}