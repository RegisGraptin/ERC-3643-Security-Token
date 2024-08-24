// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.24;

import "./interfaces/IAgentRole.sol";

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

enum Role {
    MANAGER, 
    ADMIN
}

contract AgentRole is Ownable, IAgentRole {

    // Customizable depending of the role we wants
    Role role;

    // Store agent state
    mapping (address => bool) agents;

    constructor (address _owner, Role _role) Ownable(_owner) {
        role = _role;
    }

    function addAgent(address _agent) external override onlyOwner {
        require(!agents[_agent], "ALREADY_AGENT_ROLE");
        agents[_agent] = true;
    }

    function removeAgent(address _agent) external override onlyOwner {
        require(agents[_agent], "NOT_AGENT_ROLE");
        agents[_agent] = false;
    }

    function isAgent(address _agent) external view override returns (bool) {
        return agents[_agent];
    }
}