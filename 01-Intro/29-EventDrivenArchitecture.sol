// Events Advanced
// Events in Solidity are a powerful tool that enables various advanced functionalities and architectures. Some advanced use cases for events include:

// Event filtering and monitoring for real-time updates and analytics
// Event log analysis and decoding for data extraction and processing
// Event-driven architectures for decentralized applications (dApps)
// Event subscriptions for real-time notifications and updates

// Event-Driven Architecture
// The EventDrivenArchitecture contract demonstrates an event-driven architecture where events are used to coordinate and trigger different stages of a process, such as initiating and confirming transfers.

// Event Subscription and Real-Time Updates
// The EventSubscription contract showcases how to implement event subscriptions, allowing external contracts or clients to subscribe and receive real-time updates when events are emitted. It also demonstrates how to handle event subscriptions and manage the subscription lifecycle.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

// Event-Driven Architecture
contract EventDrivenArchitecture {
    event TransferInitiated(
        address indexed from, address indexed to, uint256 value
    );
    event TransferConfirmed(
        address indexed from, address indexed to, uint256 value
    );

    mapping(bytes32 => bool) public transferConfirmations;

    function initiateTransfer(address to, uint256 value) public {
        emit TransferInitiated(msg.sender, to, value);
        // ... (initiate transfer logic)
    }
    // Buscar el transaction hash generado de initiateTransfer function
    // transaction hash	0xc0a157f2843e212852575db6823d4abd43280d668a50b6d579c05a7b22f66807
    function confirmTransfer(bytes32 transferId) public {
        require(
            !transferConfirmations[transferId], "Transfer already confirmed"
        );
        transferConfirmations[transferId] = true;
        emit TransferConfirmed(msg.sender, address(this), 0);
        // ... (confirm transfer logic)
    }
}

// Event Subscription and Real-Time Updates
interface IEventSubscriber {
    function handleTransferEvent(address from, address to, uint256 value)
        external;
}

contract EventSubscription {
    event LogTransfer(address indexed from, address indexed to, uint256 value);

    mapping(address => bool) public subscribers;
    address[] public subscriberList;

    function subscribe() public {
        require(!subscribers[msg.sender], "Already subscribed");
        subscribers[msg.sender] = true;
        subscriberList.push(msg.sender);
    }

    function unsubscribe() public {
        require(subscribers[msg.sender], "Not subscribed");
        subscribers[msg.sender] = false;
        for (uint256 i = 0; i < subscriberList.length; i++) {
            if (subscriberList[i] == msg.sender) {
                subscriberList[i] = subscriberList[subscriberList.length - 1];
                subscriberList.pop();
                break;
            }
        }
    }

    function transfer(address to, uint256 value) public {
        emit LogTransfer(msg.sender, to, value);
        for (uint256 i = 0; i < subscriberList.length; i++) {
            IEventSubscriber(subscriberList[i]).handleTransferEvent(
                msg.sender, to, value
            );
        }
    }
}

contract Subscriber is IEventSubscriber {
    event ReceivedTransfer(address from, address to, uint256 value);

    function handleTransferEvent(address from, address to, uint256 value) external override {
        // Lógica personalizada del suscriptor
        emit ReceivedTransfer(from, to, value); // Emite un evento propio
    }
}
