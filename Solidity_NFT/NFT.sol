pragma solidity ^0.5.6;
interface ERC165 {
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}
interface ERC721TokenReceiver {
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes4 _data) external returns(bytes4);
}

contract ERC721Implemntation {
    mapping (uint256 => address) tokenOwner;
    mapping (address => uint256) ownedTokenCount;
    mapping (address=>mapping(address => bool)) operatorApprovals;
    mapping(uint256 => address) private tokenApprovals;

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    string private _name;
    string private _symbol;
    address payable private _master;

    constructor(string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _master = msg.sender;
    }

    function name() public view returns (string memory){
        return _name;
    }

    function symbol() public view returns (string memory){
        return _symbol;
    }

    function master() public view returns (address payable){
        return _master;
    }

    function mint(address _to, uint _tokenId) public {
        require(_to != address(0));
        require(!_exists(_tokenId));
        tokenOwner[_tokenId] = _to;
        ownedTokenCount[_to] += 1;
        emit Transfer(address(0), _to, _tokenId);
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

    function transferFrom(address _from, address _to, uint256 _tokenId) internal{
        address owner = ownerOf(_tokenId);
        require(msg.sender == owner || msg.sender == getApproved(_tokenId));
        require(_from != address(0) && _to != address(0));

        tokenOwner[_tokenId] = _to;
        ownedTokenCount[_from] -= 1;
        ownedTokenCount[_to] += 1;
        emit Transfer(_from, _to, _tokenId);
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