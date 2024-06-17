// Define the RPG game contract for hunting NFTs on StarkNet

// Struct to represent player data
struct Player {
    uint256 id;
    uint256 xPos;
    uint256 yPos;
    uint256 lastHuntTime;
    uint256 nftsCollected;
}

// Struct to represent NFTs
struct NFT {
    uint256 id;
    uint256 xPos;
    uint256 yPos;
    bool isCollected;
}

// State variables
var players: map(account_id, Player);
var nfts: map(uint256, NFT);

// Initialize the RPG game contract
pub fn init() {
    // Initialize contract state, e.g., place NFTs on the map
    // For simplicity, let's assume NFTs are predefined in the map
    nfts[1] = NFT(1, 10, 10, false);
    nfts[2] = NFT(2, 15, 20, false);
    // Initialize other variables as needed
}


// Function to allow a player to move on the map
pub fn movePlayer(x: uint256, y: uint256) {
    let sender = msg.sender;
    let player = players[sender];
    
    // Update player's position
    players[sender] = Player(player.id, x, y, player.lastHuntTime, player.nftsCollected);
}

// Function to allow a player to hunt and collect an NFT
pub fn huntNFT(nftId: uint256) {
    let sender = msg.sender;
    let player = players[sender];
    let nft = nfts[nftId];
    
    // Ensure the player is within range to hunt the NFT (simplified range check)
    if (player.xPos == nft.xPos && player.yPos == nft.yPos && !nft.isCollected) {
        // Update NFT status to collected
        nfts[nftId].isCollected = true;
        
        // Update player's NFT collection count
        players[sender] = Player(player.id, player.xPos, player.yPos, env.now(), player.nftsCollected + 1);
    }
}
// Define events for logging
event PlayerMoved(account_id player, uint256 xPos, uint256 yPos);
event NFTCollected(uint256 nftId, account_id player);


// Function to retrieve player data
pub fn getPlayerData(accountId: account_id) -> Player {
    return players[accountId];
}

// Function to retrieve NFT data
pub fn getNFTData(nftId: uint256) -> NFT {
    return nfts[nftId];
}
