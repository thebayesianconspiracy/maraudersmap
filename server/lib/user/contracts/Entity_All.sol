contract ErrorCodes {

    enum ErrorCodes {
        NULL,
        SUCCESS,
        ERROR,
        NOT_FOUND,
        EXISTS,
        RECURSIVE,
        INSUFFICIENT_BALANCE
    }
}

contract Version {
  uint version;
}

contract Util {
  function stringToBytes32(string memory source) returns (bytes32 result) {
      assembly {
          result := mload(add(source, 32))
      }
  }

  function b32(string memory source) returns (bytes32) {
    return stringToBytes32(source);
  }
}


contract EntityType {

    enum EntityType {
        NULL,
        Farmer,
        Govt,
        Transporter,
        Retail_Stores
    }
}

contract FarmerType {

    enum FarmerType {
        NULL,
        Organic,
        Regular
    }
}

contract GovtVerification {

    enum GovtVerification {
        Verified,
        UnVerified,
        Illegal
    }
}

contract Entity is ErrorCodes, Version, EntitiyType, FarmerType, GovtVerification {
  EntityType public entityType;
  FarmerType public farmerType;
  address public account;
  string public entityName;
  bytes32 public pwHash;
  bytes32 pubKey;  
  uint public id;
  GovtVerification public govtVerification;


  function Entity(address _account, string _entityname, bytes32 _pwHash, uint _id, EntityType _entityType, FarmerType _farmerType, byte32 _pubKey, GovtVerification _govtVerification) {
    account = _account;
    entityName = _entityName;
    pwHash = _pwHash;
    entityType = _entityType;
    version = 1;
    id = _id;
    farmerType = _farmerType;
    pubKey = _pubKey;
    govtVerification = _govtVerification;
  }

  function authenticate(bytes32 _pwHash) returns (bool) {
    return pwHash == _pwHash;
  }

  function setVerification(GovtVerification _govtVerification) {
    govtVerification = _govtVerification;
  }

  function getVerification() returns (GovtVerification) {
    return govtVerification;
  }
}

contract EntityManager is ErrorCodes, Util, EntityType, FarmerType, GovtVerification {
  Entity[] entities;
  /*
    note on mapping to array index:
    a non existing mapping will return 0, so 0 should not be a valid value in a map,
    otherwise exists() will not work
  */
  mapping (bytes32 => uint) entityToIdMap;

  /**
  * Constructor
  */
  function EntityManager() {
    entities.length = 1; // see above note
  }

  function exists(string username) returns (bool) {
    return usernameToIdMap[b32(username)] != 0;
  }

  function getEntity(string entityName) returns (address) {
    uint entityId = entityToIdMap[b32(entityName)];
    return Entities[entityId];
  }

  function setVerification(string entityName, GovtVerification govtVerification) returns (address) {
    //TODO Allow only for govt
    uint entityId = entityToIdMap[b32(entityName)];
    if (!exists(entityName)) return ErrorCodes.NOT_FOUND;
    Entities[entityId].setVerification(govtVerification);
  }

  function getVerification(string entityName) returns (address) {
    uint entityId = entityToIdMap[b32(entityName)];
    return Entities[entityId].getVerification();
  }

  function createEntity(address account, string entityName, bytes32 pwHash, EntityType entityType, FarmerType farmerType, byte32 pubKey) returns (ErrorCodes) {
    // name must be < 32 bytes
    if (bytes(entityName).length > 32) return ErrorCodes.ERROR;
    // fail if entityName exists
    if (exists(entityName)) return ErrorCodes.EXISTS;
    // add user
    uint entityId = Entities.length;
    entityToIdMap[b32(entityName)] = entityId;
    entities.push(new Entity(account, entityName, pwHash, entityId, entityType, farmerType, pubKey, GovtVericiation.UnVerified));
    return ErrorCodes.SUCCESS;
  }

  function login(string entityName, bytes32 pwHash) returns (bool) {
    // fail if username doesnt exists
    if (!exists(entityName)) return false;
    // get the user
    address a = getEntity(entityName);
    Entity entity = Entity(a);
    return entity.authenticate(pwHash);
  }
}









































contract EntityManager is ErrorCodes, Util, EntityType {
  Entity[] Entities;
 
  mapping (bytes32 => address) EntityNameToAddressMap;

  /**
  * Constructor
  */
  function EntityManager() {
    Entities.length = 1; // see above note
  }

  function exists(string entityName) returns (bool) {
    return EntityNameToAddressMap[b32(entityName)] != 0;
  }

  function getEntity(string entityName) returns (address) {
    uint EntityId = EntityNameToAddressMap[b32(entityName)];
    return Entities[EntityId];
  }

  function createEntity(address account, string entityName, bytes32 pwHash, EntityType entityType) returns (ErrorCodes) {
    // name must be < 32 bytes
    if (bytes(entityName).length > 32) return ErrorCodes.ERROR;
    // fail if entityName exists
    if (exists(entityName)) return ErrorCodes.EXISTS;
    // add Entity
    uint EntityId = Entities.length;
    EntityNameToIdMap[b32(entityName)] = EntityId;
    Entities.push(new Entity(account, entityName, pwHash, EntityId, role));
    return ErrorCodes.SUCCESS;
  }

  function login(string entityName, bytes32 pwHash) returns (bool) {
    // fail if entityName doesnt exists
    if (!exists(entityName)) return false;
    // get the Entity
    address a = getEntity(entityName);
    Entity Entity = Entity(a);
    return Entity.authenticate(pwHash);
  }
}
