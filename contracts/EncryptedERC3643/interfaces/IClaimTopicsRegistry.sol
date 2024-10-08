// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.24;

interface IClaimTopicsRegistry {

   /**
    *  this event is emitted when a claim topic has been added to the ClaimTopicsRegistry
    *  the event is emitted by the 'addClaimTopic' function
    *  `claimTopic` is the required claim added to the Claim Topics Registry
    */
    event ClaimTopicAdded(uint256 indexed claimTopic);

   /**
    *  this event is emitted when a claim topic has been removed from the ClaimTopicsRegistry
    *  the event is emitted by the 'removeClaimTopic' function
    *  `claimTopic` is the required claim removed from the Claim Topics Registry
    */
    event ClaimTopicRemoved(uint256 indexed claimTopic);

   /**
    * @dev Add a trusted claim topic (For example: KYC=1, AML=2).
    * Only owner can call.
    * emits `ClaimTopicAdded` event
    * @param _claimTopic The claim topic index
    */
    function addClaimTopic(uint256 _claimTopic) external;

   /**
    *  @dev Remove a trusted claim topic (For example: KYC=1, AML=2).
    *  Only owner can call.
    *  emits `ClaimTopicRemoved` event
    *  @param _claimTopic The claim topic index
    */
    function removeClaimTopic(uint256 _claimTopic) external;

   /**
    *  @dev Get the trusted claim topics for the security token
    *  @return Array of trusted claim topics
    */
    function getClaimTopics() external view returns (uint256[] memory);

   /**
    *  @dev Transfers the Ownership of ClaimTopics to a new Owner.
    *  Only owner can call.
    *  @param _newOwner The new owner of this contract.
    */
    function transferOwnershipOnClaimTopicsRegistryContract(address _newOwner) external;
}
