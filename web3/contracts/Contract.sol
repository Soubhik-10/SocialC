//SPDX-License-Identifier:MIT
error AlreadyAnUser();
error InvalidAccess();
pragma solidity ^0.8.20;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/extensions/ERC20Burnable.sol";
contract ICSToken is ERC20, ERC20Burnable {
    address payable owner;

    constructor(uint256 initialSupply) ERC20("ICSToken", "ICS") {
        owner = payable(msg.sender);
        _mint(msg.sender, initialSupply * (10 ** decimals()));
    }

    function mint(address account, uint value) public {
        _mint(account, value * (10 ** decimals()));
    }

    function destroy() public onlyOwner {
        selfdestruct(owner);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "only the owner can call this function");
        _;
    }
}

contract SocialC{
    address immutable owner;
    ICSToken public icstoken;
 constructor(address ot) {
        icstoken = ICSToken(ot);
        owner = (msg.sender);
        icstoken.mint(address(this), 30000000 * (10 ** icstoken.decimals()));
        icstoken.approve(address(this), 300000 * (10 ** icstoken.decimals()));
        icstoken.allowance(msg.sender, address(this));
    }
struct Message {
        uint256 mid;
        address creator;
        string image_hash;
        string content;
        uint256 timestamp;
        bool encrypted;
        address reciever;//handle like tags
       bool groupmsg;
       uint256 gid;
         }
    struct EncryptedMessage{
        string nonce;
        string ciphertext;
        uint256 mid;
        
    }
    struct Group{
        uint256 gid;
        address creator;
        address [] members;
        bool creationSuccess;
        string name;
        string description;
        string  imageHash;
    }
    struct User {
        uint256 uid;
        address userid;
        string name;
        string bio;
        string image_hash;
        string caption;
        string contactdetails;
        uint256 dailycheckin;
        uint256[] dailycheckins;
        uint256[] mids;
        uint256[] gids;
        uint256 token;
        bool premiumUser;
        uint256 timestampBan;
    }
    mapping(address => bool) public isAUser;
    mapping(address => bool) private gotInitial;
    mapping(address => User) public userCheck;
    mapping(uint256 => Message) public messages;
    mapping(address=>mapping(address=>uint256[])) public msgSent;
    mapping(address=>mapping(address=>uint256[]))public msgRecieved;
    mapping(uint256=>mapping(address=>uint256[]))public msgInGroup;
    mapping(uint256=>uint256[])groupMsg;
    mapping(address=>mapping(address=>bool))blocks;
    mapping(address=>bool)banned;
    mapping(uint256 => User) public users;
    mapping(uint256=>address[])public listOfUsers;
    mapping(uint256=>Group)public groups;
    mapping(uint256=>EncryptedMessage)public encryptedStorage;
    mapping(uint256=>EncryptedMessage)public midToEncrypted;
      User[] userArray;
    uint256 totalUserCount = 0;
    uint256 midCount = 0;
    uint256 encryptedMidCount=0;
    uint256 groupCount=0;
    uint256  registerCount=0;
    function register(
        string memory _name,
        string memory _bio,
        string memory _image_hash,
        string memory _caption,
        string memory _contactdetails
    ) external {
        if (isAUser[msg.sender] == true) revert AlreadyAnUser();
        totalUserCount++;
        User storage user = users[totalUserCount];
        user.uid = totalUserCount;
        user.userid = msg.sender;
        user.name = _name;
        user.bio = _bio;
        user.image_hash=(_image_hash);
        user.caption = _caption;
        user.contactdetails=_contactdetails;
        user.premiumUser=false;
        userCheck[msg.sender] = user;
        isAUser[msg.sender] = true;
        userArray.push(user);
        sendInitial();
    }
    function getPremium()external{
        require(isAUser[msg.sender] == true, "only users can get premium");
        icstoken.transferFrom(
           msg.sender,
            address(this),
            200 * (10 ** icstoken.decimals())
        );
        userCheck[msg.sender].token = icstoken.balanceOf(msg.sender);
        userCheck[msg.sender].premiumUser=true;
    }
    function createGroup(string memory _name,string memory _description,string memory _imagehash)external{
         require(isAUser[msg.sender] == true, "only users can create grp");
         groupCount++;
         Group storage group=groups[groupCount];
         group.gid=groupCount;
         group.creator=msg.sender;
         group.creationSuccess=true;
         group.name=_name;
         group.description=_description;
         group.imageHash=_imagehash;
         listOfUsers[group.gid].push(msg.sender);
         group.members.push(msg.sender);
         if(userCheck[msg.sender].premiumUser==true){
               icstoken.transferFrom(
           msg.sender,
            address(this),
            6 * (10 ** icstoken.decimals())
        );
         }
         else{
             icstoken.transferFrom(
           msg.sender,
            address(this),
            10 * (10 ** icstoken.decimals())
        );
         }
         userCheck[msg.sender].token = icstoken.balanceOf(msg.sender);
         userCheck[msg.sender].gids.push(group.gid);
    }
    function createMessage(
        string memory _imageHash,
        string memory _content,
        address _reciever
    ) external {
        require(isAUser[msg.sender] == true, "only users can create msg");
        require(banned[msg.sender]==false,"user banned");
        midCount++;
        Message storage message = messages[midCount];
       message.mid = midCount;
        message.creator = (msg.sender);
        message.image_hash = _imageHash;
        message.content = _content;
        message.timestamp=block.timestamp;
        message.reciever=_reciever;
        message.encrypted=false;
       require(blocks[msg.sender][message.reciever]==false,"reciever is blocked");
        require(blocks[message.reciever][msg.sender]==false,"user is blocked");
        msgSent[msg.sender][message.reciever].push(message.mid);
        userCheck[msg.sender].mids.push(message.mid);
    }
     function createMessageForGrp(
        string memory _imageHash,
        string memory _content,
        uint256 _gid
    ) external {
        require(isAUser[msg.sender] == true, "only users can create msg");
        require(banned[msg.sender]==false,"user banned");
        midCount++;
        Message storage message = messages[midCount];
       message.mid = midCount;
        message.creator = (msg.sender);
        message.image_hash = _imageHash;
        message.content = _content;
        message.timestamp=block.timestamp;
        message.encrypted=false;
        message.groupmsg=true;
            message.gid=_gid;
            groupMsg[message.gid].push(message.mid);
            msgInGroup[message.gid][msg.sender].push(message.mid);
            userCheck[msg.sender].mids.push(message.mid);
    } 
function createMessageEncryptionForGrp(
        uint256 _gid,
        string memory _nonce,
        string memory _ciphertext
    ) external {
        require(isAUser[msg.sender] == true, "only users can create msg");
        require(banned[msg.sender]==false,"user banned");
        midCount++;
        Message storage message = messages[midCount];
       message.mid = midCount;
        message.creator = (msg.sender);
        message.timestamp=block.timestamp;
        message.encrypted=true;
        message.groupmsg=true;
            encryptedMidCount++;
            EncryptedMessage storage encrypt=encryptedStorage[encryptedMidCount];
            encrypt.nonce=_nonce;
            encrypt.ciphertext=_ciphertext;
            encrypt.mid=midCount;
            message.gid=_gid;
             groupMsg[message.gid].push(message.mid);
            msgInGroup[message.gid][msg.sender].push(message.mid);
            midToEncrypted[message.mid]=encrypt;
            if(userCheck[msg.sender].premiumUser==true){
                icstoken.transferFrom(
           msg.sender,
            address(this),
            2 * (10 ** icstoken.decimals())
        );
            }
            else{
                icstoken.transferFrom(
           msg.sender,
            address(this),
            4 * (10 ** icstoken.decimals())
        );
            }

        
        userCheck[msg.sender].mids.push(message.mid);
    }
    function createMessageEncryption(
        address  _reciever,
        string memory _nonce,
        string memory _ciphertext
    ) external {
        require(isAUser[msg.sender] == true, "only users can create msg");
        require(banned[msg.sender]==false,"user banned");
        midCount++;
        Message storage message = messages[midCount];
       message.mid = midCount;
        message.creator = (msg.sender);
        message.timestamp=block.timestamp;
        message.reciever=_reciever;
        message.encrypted=true;
         encryptedMidCount++;
            EncryptedMessage storage encrypt=encryptedStorage[encryptedMidCount];
            encrypt.nonce=_nonce;
            encrypt.ciphertext=_ciphertext;
            encrypt.mid=midCount; 
            require(blocks[msg.sender][message.reciever]==false,"reciever is blocked");
             require(blocks[message.reciever][msg.sender]==false,"user is blocked");
        msgSent[msg.sender][message.reciever].push(message.mid);
         midToEncrypted[message.mid]=encrypt;
          if(userCheck[msg.sender].premiumUser==true){
                icstoken.transferFrom(
           msg.sender,
            address(this),
            2 * (10 ** icstoken.decimals())
        );
            }
            else{
                icstoken.transferFrom(
           msg.sender,
            address(this),
            4 * (10 ** icstoken.decimals())
        );
            }

       
        
        
        userCheck[msg.sender].mids.push(message.mid);
    }
      

    function getBalance(address a) public view returns (uint256) {
        return icstoken.balanceOf(a);
    }

    function sendInitial() internal {
        registerCount++;
        icstoken.transferFrom(
            address(this),
            msg.sender,
            10 * (10 ** icstoken.decimals())
        );
        userCheck[msg.sender].token = icstoken.balanceOf(msg.sender);
        gotInitial[msg.sender] = true;
    }


    //send money to creator
    function sendMoney(address _userid, uint256 _amount) external {
        
        require(isAUser[msg.sender] == true, "should be user");
        require(isAUser[_userid]==true,"should be user");
        require(_amount <= icstoken.balanceOf(msg.sender), "not possible");
        icstoken.transferFrom(
            msg.sender,
           _userid,
            _amount * (10 ** icstoken.decimals())
        );
        userCheck[msg.sender].token = icstoken.balanceOf(msg.sender);
        userCheck[_userid].token = icstoken.balanceOf(_userid);
    }
    function updateProfilePic(string memory _image_hash)external{
         require(isAUser[msg.sender] == true, "should be user");
         userCheck[msg.sender].image_hash=_image_hash;
    
    }
    function updateGroupPic(string memory _image_hash,uint256 _gid)external{
         require(isAUser[msg.sender] == true, "should be user");
         require(_gid<=groupCount,"invalid gid");
         groups[_gid].imageHash=_image_hash;
       
    }
    function blockUser(address _user)external{
           require(isAUser[msg.sender] == true, "should be user");
              require(isAUser[_user] == true, "should be user");
              if(blocks[msg.sender][_user]==true){
                blocks[msg.sender][_user]=false;
              }
              else{
                blocks[msg.sender][_user]=true;
              }
    }
    function banUser(address _user)external{
        require(msg.sender==owner,"only owner can ban");
        require(isAUser[_user]==true,"to be banned must be user");
        if(banned[_user]==true){
            if((block.timestamp-userCheck[_user].timestampBan)>=24 hours){
                banned[_user]=false;
            }

        }
        else{
            banned[_user]=true;
        }
    }
    function updateGroupMember(uint256 _gid,address _user)external{
       
        require(isAUser[_user]==true," must be user");
        require (_gid<=groupCount,"invalid");
          require(msg.sender==groups[_gid].creator,"only creator can add");
        listOfUsers[_gid].push(_user);
           groups[_gid].members.push(_user);
        userCheck[_user].gids.push(_gid);
    }
    function updateMessageRecieve(uint256 _mid,address _user)external{
         require(msg.sender==owner,"only owner can add");
        require(isAUser[_user]==true," must be user");
          require (_mid<=midCount,"invalid");
          address a=messages[_mid].creator;
          if(messages[_mid].groupmsg==false){
          msgRecieved[_user][a].push(_mid);
          }
          userCheck[_user].mids.push(_mid);

    }
    function deleteMessageUser(address _user)external{
         require(isAUser[_user]==true," must be user");
          require(isAUser[msg.sender]==true," must be user");
          if(msgSent[msg.sender][_user].length!=0){
            msgSent[msg.sender][_user].pop();
            if(userCheck[msg.sender].premiumUser==true){
                 icstoken.transferFrom(
           msg.sender,
            address(this),
            1 * (10 ** icstoken.decimals())
        );
            }
            else{
                 icstoken.transferFrom(
           msg.sender,
            address(this),
            2 * (10 ** icstoken.decimals())
        );
            }
          }
    }
    function deleteGroupMessage(uint256 _gid)external{
         require(isAUser[msg.sender]==true," must be user");
         require(_gid<=groupCount,"invalid");
      if(msgInGroup[_gid][msg.sender].length!=0){
            msgInGroup[_gid][msg.sender].pop();
            if(userCheck[msg.sender].premiumUser==true){
                 icstoken.transferFrom(
           msg.sender,
            address(this),
            1 * (10 ** icstoken.decimals())
        );
            }
            else{
                 icstoken.transferFrom(
           msg.sender,
            address(this),
            2 * (10 ** icstoken.decimals())
        );
            }
          }
    }
    function checkMemberUser(address _member)external returns(bool){
        if(isAUser[_member]==true)
            return true;
            else 
            return false;
    }
    function checkBlocked(address a,address b)external returns(bool){
         require(isAUser[a]==true," must be user");
          require(isAUser[b]==true," must be user");
          require(isAUser[msg.sender]==true," must be user");
        if(blocks[a][b]==true)
            return true;
        else 
        return false;
    }
    function checkBanned(address c)external returns(bool){
         require(isAUser[c]==true," must be user");
         require(isAUser[msg.sender]==true," must be user");
         
        if(banned[c]==true)
            return true;
        else 
        return false;
    }


     function getUserById(address _user) external view returns (User memory) {
        User storage user = userCheck[_user];
        return user;
    }

    function getGroupById(uint256 _gid)external returns (Group memory){
        require(isAUser[msg.sender]==true,"not user");
        require(_gid<=groupCount,"invalid");
        bool k=checkMember(msg.sender,_gid);
        if(k==true){
        Group storage group=groups[_gid];
        return group;
        }
    }
    function checkMember(address _a,uint256 _gid)internal returns(bool){
      for(uint256 i=0;i<listOfUsers[_gid].length;i++){
            if(listOfUsers[_gid][i]==_a){
                return true;
            }
        }
        return false;
    }
    //function create another which stores all irrespective of user
   
     function getMessagesOfGrp(uint256 _gid) external returns (Message[] memory) {
    require(isAUser[msg.sender] == true, "not user");
    require(_gid<=groupCount,"invalid");
    
    uint256 messageCount = groupMsg[_gid].length;
    if (messageCount > 0) {
        Message[] memory msgInteraction = new Message[](messageCount);
        for (uint256 i = 0; i < messageCount; i++) {
            msgInteraction[i] = getMessageById( groupMsg[_gid][i]);
        }
        return msgInteraction;
    } 
}
   function getMessagesOfGrpByUser(uint256 _gid) external returns (Message[] memory) {
    require(isAUser[msg.sender] == true, "not user");
    require(_gid<=groupCount,"invalid");

    uint256 messageCount = msgInGroup[_gid][msg.sender].length;
    if (messageCount > 0) {
        Message[] memory msgInteraction = new Message[](messageCount);
        for (uint256 i = 0; i < messageCount; i++) {
            msgInteraction[i] = getMessageById( msgInGroup[_gid][msg.sender][i]);
        }
        return msgInteraction;
    } 
}
 function getMessages(address _receiver) external returns (Message[] memory) {
    require(isAUser[msg.sender] == true, "not user");
    require(isAUser[_receiver] == true, "not user");

    uint256 messageCount = msgSent[msg.sender][_receiver].length;
    if (messageCount > 0) {
        Message[] memory msgInteraction = new Message[](messageCount);
        for (uint256 i = 0; i < messageCount; i++) {
            msgInteraction[i] = getMessageById(msgSent[msg.sender][_receiver][i]);
        }
        return msgInteraction;
    } 
}
   
    function getMessageById(uint256 _mid)internal returns(Message memory){
        Message storage message=messages[_mid];
        return message;
    }
    function getEncryptedMsg(uint256 _mid)external returns(EncryptedMessage memory){
          require(_mid<=midCount,"invalid");
          if(messages[_mid].encrypted==true){
            EncryptedMessage storage em=midToEncrypted[_mid];
            return em;
          }
    }
    function dailyCheckinHandler() external {
        require(isAUser[msg.sender] == true, "should be user");
        User storage user = userCheck[msg.sender];
        if (user.dailycheckins.length == 0) {
            user.dailycheckin = 1;
            user.dailycheckins.push(block.timestamp);
            icstoken.transferFrom(
                address(this),
                msg.sender,
                15 * (10 ** icstoken.decimals())
            );
            userCheck[msg.sender].token = icstoken.balanceOf(msg.sender);
        } else if (user.dailycheckins.length > 0) {
            if (
                (block.timestamp -
                    user.dailycheckins[user.dailycheckins.length - 1]) >=
                24 hours
            ) {
                user.dailycheckin += 1;
                user.dailycheckins.push(block.timestamp);
                icstoken.transferFrom(
                    address(this),
                    msg.sender,
                    5 * (10 ** icstoken.decimals())
                );
                userCheck[msg.sender].token = icstoken.balanceOf(msg.sender);
            }
        }
    }
      function getAllUsers() external view returns (User[] memory) {
        return userArray;
    }
}