// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import '../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '../node_modules/base64-sol/base64.sol';

// 1. MINT
// -   Mint 2 NFT tokens
// -   On chain data of NFT includes: "From: Person A to Person: B" + Vows
// -   Person A's NFT is sent to Person B's Wallet and vice versa

// 2. View TOKEN

// -   View your partner's token within your wallet \
// -   View the token you gave to your partner

contract We4VerToken is ERC721 {
    address public owner;
    uint256 tokenId = 1;

    event CreatedWe4VerToken(uint256 indexed tokenId, string tokenUri);

    // Optional mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;
    // Mapping partner A's tokenId to partner B's tokenId
    mapping(uint256 => uint256) internal tokenIdToSpouseToken;

    constructor() ERC721('We4Ver', 'We4Ver') {
        owner = msg.sender;
    }

    function _setTokenURI(uint256 _tokenId, string memory _tokenURI)
        internal
        virtual
    {
        require(
            _exists(_tokenId),
            'ERC721Metadata: URI set of nonexistent token'
        );
        _tokenURIs[tokenId] = _tokenURI;
    }

    function createVowToken(
        address _to,
        uint256 _tokenId,
        string memory _text
    ) internal virtual {
        require(!_exists(_tokenId), 'Token already exists!');
        require(_to != address(0), 'ERC721: mint to the zero address');
        _safeMint(_to, _tokenId);
        string memory imageUri = formatImageUri(_text);
        string memory tokenUri = formatTokenUri(imageUri);
        _setTokenURI(_tokenId, tokenUri);
        emit CreatedWe4VerToken(tokenId, tokenUri);
        tokenId++;
    }

    // Example vowA -> To Lina: Vows...
    function exchangeVows(
        address to,
        string memory vowA,
        string memory vowB
    ) external payable {
        // Create spouse A token and send to spouse B address
        createVowToken(to, tokenId, vowA);
        // Create spouse B token and send to spouse A address
        createVowToken(msg.sender, tokenId, vowB);
    }

    function formatImageUri(string memory vowText)
        public
        pure
        returns (string memory)
    {
        string memory baseUri = 'data:text/plain;base64,';
        string memory textEncoded = Base64.encode(
            bytes(string(abi.encodePacked(vowText)))
        );
        string memory imageUri = string(abi.encodePacked(baseUri, textEncoded));
        return imageUri;
    }

    function formatTokenUri(string memory imageUri)
        public
        pure
        returns (string memory)
    {
        string memory baseUrl = 'data:application/json;base64';
        return
            string(
                abi.encodePacked(
                    baseUrl,
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name": "We4Ver NFT Marriage Token"',
                                '"description": "A marriage token with vows represented on-chain 4ever."',
                                '"image": "',
                                imageUri,
                                '"}'
                            )
                        )
                    )
                )
            );
    }
}
