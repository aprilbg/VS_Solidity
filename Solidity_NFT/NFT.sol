// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IERC721Receiver{ function onERC721Received(address operator, address from, uint256 tokenId) external returns(bytes4);}
library Counters{
    struct Counter{
        uint256 _value;
    }
    function current(Counter storage  counter)  external view returns (uint256){return counter._value;}
    function increment(Counter storage  counter)  external {unchecked {counter._value += 1;}}
    function decrement(Counter storage  counter)  external {uint256 value = counter._value;require(value > 0, "Counter: decrement overflow");unchecked {counter._value = value - 1;}}
    function reset(Counter storage  counter)  external {counter._value = 0;}
}
interface IERC721 { function setApprovalForAll(address operator, bool _approved) external;}

contract MyNFTs{
    
    address public owners;
    uint256 private _tokenIds;
    string private _name = "MyNFTs_build";
    string private _symbol = "MFT";

    mapping(uint256 => address) private _owner;
    mapping(address => uint256) private _balance;
    mapping(uint256 => address) private _tokenApporvals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal {}

    function balanceOfNFT(address owner) public view returns(uint){
        require(owner != address(0));
        return _balance[owner];
    }

    function ownerOfNFT(uint256 tokenId) public view returns(address){
        address owner = _owner[tokenId];
        require(owner != address(0));
        return owner;
    }

    function safeTransferFrom(address to,  uint256 tokenId) public returns(bool){
        _safeTransfer(msg.sender, to, tokenId);
        return true;
    }

    function _safeTransfer(address from, address to, uint256 tokenId) internal returns(bool){
        require(_checkOnERC721Received(from, to, tokenId));
        require(_owner[tokenId] == from);
        require(to != address(0));

        _beforeTokenTransfer(from, to, tokenId);
        _approve(address(0), tokenId);
        _balance[from] -= 1;
        _balance[to] += 1;
        _owner[tokenId] = to;

        emit Transfer(from, to, tokenId);
        return true;
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId) private returns(bool){
        if(msg.sender == tx.origin){
            IERC721Receiver spender = IERC721Receiver(to);
            try spender.onERC721Received(msg.sender, from, tokenId) returns(bytes4 retaval){
                return retaval == IERC721Receiver.onERC721Received.selector;
            }catch (bytes memory reason){
                if(reason.length == 0){
                    revert("ERC721 : transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function isApprovedForAll(address owner, address operator) public view returns(bool){
        return _operatorApprovals[owner][operator];
    }

    function getApproved(uint256 tokenId) public view returns(address){
        require(_exists(tokenId), "ERC721 : invalid token ID");
        return _tokenApporvals[tokenId];
    }

    function _approve(address to, uint256 tokenId) internal{
        _tokenApporvals[tokenId] = to;
        emit Approval(_owner[tokenId], to, tokenId);
    }

    function setApprovalForAll(address operator, bool approved) public{
        _setApprovalForAll(msg.sender, operator, approved);
    } 
    function _setApprovalForAll(address owner, address operator, bool approved) internal{
        require(owner != operator, "Error : approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns(bool){
        address owner = _owner[tokenId];
        return(spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    function _safeMint(address to, uint256 tokenId) internal returns(bool){
        require(to != address(0),"ERC721 : mint to the zero address");
        require(!_exists(tokenId), "ERC721 : token already minted");
        _beforeTokenTransfer(address(0), to, tokenId);
        _balance[to] += 1;
        _owner[tokenId] = to;
        emit Transfer(address(0), to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId), "ERC721: transfer to non ERC721Receiver implementer");
        return true;
    }

    function _exists(uint256 tokenId) internal view returns(bool){
        return _owner[tokenId] != address(0);
    }

    function _burn(uint256 tokenId) internal returns (bool){
        address owner = _owner[tokenId];
        _beforeTokenTransfer(owner, address(0), tokenId);
        _approve(address(0), tokenId);
        _balance[owner] -= 1;
        delete _owner[tokenId];

        emit Transfer(owner, address(0), tokenId);
        return true;
    }

    function minting() public returns(uint256){
        _tokenIds += 1;
        uint256 newItemId = _tokenIds;
        _safeMint(msg.sender, newItemId);
        return newItemId;
    }
}