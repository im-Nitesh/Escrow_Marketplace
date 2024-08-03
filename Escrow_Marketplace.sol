// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

contract EscrowMarketplace {
    struct Item {
        string name;
        uint256 price;
        address payable seller;
        address payable buyer;
        bool isSold;
    }

    mapping(string => Item) public items;

    event ItemListed(string name, uint256 price, address indexed seller);
    event ItemBought(string name, address indexed buyer);
    event ItemConfirmed(string name, address indexed buyer, address indexed seller);

    // Function to list an item for sale
    function listItem(string memory _name, uint256 _price) external {
        require(items[_name].seller == address(0), "Item already listed");

        items[_name] = Item({
            name: _name,
            price: _price,
            seller: payable(msg.sender),
            buyer: payable(address(0)),
            isSold: false
        });

        emit ItemListed(_name, _price, msg.sender);
    }

    // Function for buyer to buy an item
    function buyItem(string memory _name) external payable {
        Item storage item = items[_name];
        require(item.seller != address(0), "Item not found");
        require(!item.isSold, "Item already sold");
        require(msg.value == item.price, "Incorrect price");

        item.buyer = payable(msg.sender);
        item.isSold = true;

        emit ItemBought(_name, msg.sender);
    }

    // Function for buyer to confirm receipt of the item
    function confirmReceipt(string memory _name) external {
        Item storage item = items[_name];
        require(item.buyer == msg.sender, "Only buyer can confirm receipt");
        require(item.isSold, "Item not sold");

        item.seller.transfer(item.price);

        emit ItemConfirmed(_name, msg.sender, item.seller);

        // Remove the item from the mapping to free up storage
        delete items[_name];
    }

    // Function for dispute resolution (For simplicity, refund to buyer in this example)
    function disputeResolution(string memory _name) external {
        Item storage item = items[_name];
        require(item.isSold, "Item not sold");
        require(item.buyer == msg.sender || item.seller == msg.sender, "Only buyer or seller can raise dispute");

        // Refund the buyer
        item.buyer.transfer(item.price);

        emit ItemConfirmed(_name, item.buyer, item.seller);

        // Remove the item from the mapping to free up storage
        delete items[_name];
    }
}
