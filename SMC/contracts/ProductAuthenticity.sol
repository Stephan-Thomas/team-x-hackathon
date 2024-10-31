// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ProductAuthenticity is ERC1155, Ownable {
    // Struct to store product details
    struct Product {
        uint256 id;
        string name;
        address manufacturer;
    }

    // Mapping from product ID to Product details
    mapping(uint256 => Product) public products;

    // Mapping to keep track of approved retailers
    mapping(address => bool) public approvedRetailers;

    // Event emitted when a new product is created
    event ProductCreated(uint256 productId, address manufacturer, string name);

    // Event emitted when a retailer is approved or removed
    event RetailerApprovalUpdated(address retailer, bool approved);

    constructor() ERC1155("https://api.example.com/metadata/{id}.json") Ownable(msg.sender) {}

    // Function to create a new product token
    function createProduct(uint256 _id, string memory _name) external onlyOwner {
        require(products[_id].id == 0, "Product already exists");

        // Create a new product and store details
        products[_id] = Product(_id, _name, msg.sender);

        // Mint a unique token (non-fungible) for the product
        _mint(msg.sender, _id, 1, "");

        emit ProductCreated(_id, msg.sender, _name);
    }

    // Function to update retailer approval
    function updateRetailerApproval(address _retailer, bool _approved) external onlyOwner {
        approvedRetailers[_retailer] = _approved;
        emit RetailerApprovalUpdated(_retailer, _approved);
    }

    // Function for a retailer to transfer product tokens to a consumer
    function transferProduct(address _to, uint256 _id) external {
        require(approvedRetailers[msg.sender], "Retailer not approved");
        require(balanceOf(msg.sender, _id) > 0, "No product token available");

        // Transfer the product token to the consumer
        safeTransferFrom(msg.sender, _to, _id, 1, "");
    }

    // Function to check product authenticity
    function isAuthentic(uint256 _id, address _retailer) external view returns (bool) {
        Product memory product = products[_id];
        return (product.manufacturer != address(0) && approvedRetailers[_retailer]);
    }
}
