// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// 🔹 Library to allow writing to any storage slot
library StorageHandler {
    // 🔹 A wrapper struct for storing an address in a specific storage slot
    struct AddressStorage {
        address value;
    }

    // 🔹 Retrieves a reference to the storage slot using assembly
    function getSlot(bytes32 slot)
        internal
        pure
        returns (AddressStorage storage slotRef)
    {
        assembly {
            // Assigns the slot to the reference
            slotRef.slot := slot
        }
    }
}

// 🔹 Main contract that demonstrates reading/writing to a storage slot
contract StorageManager {
    // 📌 Define a constant slot identifier
    bytes32 public constant CUSTOM_SLOT = keccak256("CUSTOM_STORAGE_SLOT");

    // 🔹 Store an address in the custom storage slot
    function storeAddress(address _newAddress) external {
        StorageHandler.AddressStorage storage slotData =
            StorageHandler.getSlot(CUSTOM_SLOT);
        slotData.value = _newAddress;
    }

    // 🔹 Retrieve the stored address from the custom storage slot
    function retrieveAddress() external view returns (address) {
        StorageHandler.AddressStorage storage slotData =
            StorageHandler.getSlot(CUSTOM_SLOT);
        return slotData.value;
    }
}
