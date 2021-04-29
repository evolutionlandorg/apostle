pragma solidity ^0.4.24;

contract Authority {
    event Rely(address indexed usr);
    event Deny(address indexed usr);
    event Allow(bytes4 indexed usr);
    event Forbid(bytes4 indexed usr);
    event SetRoot(address indexed newRoot);

    address public root;
    mapping (address => uint) public wards;
    mapping (bytes4 => uint)  public sigs;
    modifier sudo                               { require(msg.sender == root); _; }
    function setRoot(address usr) external sudo { root = usr; emit SetRoot(usr); }
    function rely(address usr)    external sudo { wards[usr] = 1; emit Rely(usr); }
    function deny(address usr)    external sudo { wards[usr] = 0; emit Deny(usr); }
    function allow(bytes4 sig)    external sudo { sigs[sig] = 1; emit Allow(sig); }
    function forbid(bytes4 sig)   external sudo { sigs[sig] = 1; emit Forbid(sig); }

    constructor(address[] _wards, bytes4[] _sigs) public {
        root = msg.sender;
        emit SetRoot(root);
        for (uint i = 0; i < _wards.length; i ++) { rely(_wards[i]); }
        for (uint i = 0; i < _sigs.length; i++) { allow(_sigs[i]); }
    }

    function canCall(
        address _src, address, bytes4 _sig
    ) public view returns (bool) {
        return ( wards[_src] == 1 && sigs[_sig] == 1) 
    }
}
