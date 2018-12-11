# apostle
apostle contracts

### create gen0 apostle
only authorized operator can do this.

```python
gen0Apostle.createGen0Apostle(uint245 _genes, uint256 _talents)
```
note that limit for number of gen0 apostles is set in contract.

### create gen0 auction
only authorized operator can do this.
```python
gen0Apostle.createGen0Auction(uint256 _tokenId,
                                      uint256 _startingPriceInToken,
                                      uint256 _endingPriceInToken,
                                      uint256 _duration,
                                      uint256 _startAt,
                                      address _token))
```
`_token` is the specific token which can be used to bid for this apostle.

### create apostle auction (general)
any one who owns an apostle can call this.
```python
objectOwnership.approveAndCall(address(ApostleClockAuction), apostleTokenId, extraData)
```
`extraData = bytes32(startingPrice) + bytes32(endingPrice) + bytes32(duration) + bytes32(seller)`
note that bytes32 occupy 64 bits, these 4 parts are concated as string and start with 0x.

### bid apostle in ApostleClockAuction
```python
ring.transfer(address(ApostleClockAuction), amountOfRing, extraData)
```
`extraData = bytes32(tokenId)`
tokenId here is what you bid.


### create siring auction
```python
objectOwnership.approveAndCall(address(SiringClockAuction), apostleTokenId, extraData)
```
`extraData = bytes32(startingPrice) + bytes32(endingPrice) + bytes32(duration) + bytes32(seller)`

### bid apostle in SiringClockAuction
```python
ring.transfer(address(SiringClockAuction), value, extraData)
```
`extraData = bytes32(tokenId) + bytes32(referer_address)`

