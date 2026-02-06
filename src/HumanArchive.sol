// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract HumanArchive {
    /// @notice Merkle root anchoring all photo hashes for the current batch.
    bytes32 public merkleRoot;
    address public owner;

    event RootUpdated(bytes32 indexed previousRoot, bytes32 indexed newRoot);

    error NotOwner();

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    /// @notice Owner updates the Merkle root created off-chain from photo hashes.
    function setMerkleRoot(bytes32 newRoot) external onlyOwner {
        bytes32 previousRoot = merkleRoot;
        merkleRoot = newRoot;
        emit RootUpdated(previousRoot, newRoot);
    }

    /// @notice Verifies a photo hash is included in the anchored Merkle root.
    /// @param leaf keccak256 hash representing the photo (or its encoding rule).
    /// @param proof Merkle sibling hashes from leaf up to the root.
    function verify(bytes32 leaf, bytes32[] calldata proof) external view returns (bool) {
        return MerkleProof.verify(proof, merkleRoot, leaf);
    }
}

/// @dev Minimal Merkle proof verification (same ordering rules as OpenZeppelin).
library MerkleProof {
    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32 computedHash) {
        computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
    }

    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {
        return a < b ? keccak256(abi.encodePacked(a, b)) : keccak256(abi.encodePacked(b, a));
    }
}
