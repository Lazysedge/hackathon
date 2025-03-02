import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Time "mo:base/Time";
import Option "mo:base/Option";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import TrieMap "mo:base/TrieMap";
import Hash "mo:base/Hash";
import Types "./Types";
import Blob "mo:base/Blob";
import SHA256 "mo:base/SHA246";
import Nat8 "mo:base/Nat8";
import Buffer "mo:base/Buffer";

actor class Auth() {
  type User = Types.User;
  type Error = Types.Error;
  type UserResult = Types.UserResult;

  private var users = TrieMap.TrieMap<Principal, User>(Principal.equal, Principal.hash);
  
  private var emailToUser = TrieMap.TrieMap<Text, Principal>(Text.equal, Text.hash);

  private func hashPassword(password: Text): Text {
    let passwordBlob = Text.encodeUtf8(password);
    let hash = SHA256.sha256(Blob.toArray(passwordBlob));
    let hashBuffer = Buffer.Buffer<Text>(hash.size());
    
    for (byte in hash.vals()) {
      let byteText = Nat8.toText(byte);
      hashBuffer.add(byteText);
    };
    
    return Text.join("", hashBuffer.vals());
  };

  public shared(msg) func register(username: Text, email: Text, password: Text): async UserResult {
    let caller = msg.caller;
    
    switch (emailToUser.get(email)) {
      case (?existingUser) {
        return #err(#AlreadyExists);
      };
      case (null) {
        let passwordHash = hashPassword(password);
        let now = Time.now();
        
        let newUser: User = {
          id = caller;
          username = username;
          email = email;
          passwordHash = passwordHash;
          createdAt = now;
          updatedAt = now;
        };
        
        users.put(caller, newUser);
        emailToUser.put(email, caller);
        
        return #ok(newUser);
      };
    };
  };

  public shared(msg) func login(email: Text, password: Text): async UserResult {
    switch (emailToUser.get(email)) {
      case (?userId) {
        switch (users.get(userId)) {
          case (?user) {
            let hashedPassword = hashPassword(password);
            if (Text.equal(hashedPassword, user.passwordHash)) {
              return #ok(user);
            } else {
              return #err(#NotAuthorized);
            };
          };
          case (null) {
            return #err(#NotFound);
          };
        };
      };
      case (null) {
        return #err(#NotFound);
      };
    };
  };

  public shared(msg) func getProfile(): async UserResult {
    let caller = msg.caller;
    
    switch (users.get(caller)) {
      case (?user) {
        return #ok(user);
      };
      case (null) {
        return #err(#NotFound);
      };
    };
  };

  public shared(msg) func updateProfile(username: ?Text): async UserResult {
    let caller = msg.caller;
    
    switch (users.get(caller)) {
      case (?user) {
        let updatedUsername = Option.get(username, user.username);
        
        let updatedUser: User = {
          id = user.id;
          username = updatedUsername;
          email = user.email;
          passwordHash = user.passwordHash;
          createdAt = user.createdAt;
          updatedAt = Time.now();
        };
        
        users.put(caller, updatedUser);
        return #ok(updatedUser);
      };
      case (null) {
        return #err(#NotFound);
      };
    };
  };

  public query func userExists(principal: Principal): async Bool {
    Option.isSome(users.get(principal))
  };
  
  public query func getUserByEmail(email: Text): async UserResult {
    switch (emailToUser.get(email)) {
      case (?userId) {
        switch (users.get(userId)) {
          case (?user) {
            return #ok(user);
          };
          case (null) {
            return #err(#NotFound);
          };
        };
      };
      case (null) {
        return #err(#NotFound);
      };
    };
  };

  public shared(msg) func changePassword(oldPassword: Text, newPassword: Text): async UserResult {
    let caller = msg.caller;
    
    switch (users.get(caller)) {
      case (?user) {
        let hashedOldPassword = hashPassword(oldPassword);
        if (Text.equal(hashedOldPassword, user.passwordHash)) {
          let newPasswordHash = hashPassword(newPassword);
          
          let updatedUser: User = {
            id = user.id;
            username = user.username;
            email = user.email;
            passwordHash = newPasswordHash;
            createdAt = user.createdAt;
            updatedAt = Time.now();
          };
          
          users.put(caller, updatedUser);
          return #ok(updatedUser);
        } else {
          return #err(#NotAuthorized);
        };
      };
      case (null) {
        return #err(#NotFound);
      };
    };
  };
}