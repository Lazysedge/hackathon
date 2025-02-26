import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Blob "mo:base/Blob";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Time "mo:base/Time";

actor {
  // Type definitions
  type UserId = Nat;
  type PhotoId = Nat;
  
  type User = {
    id: UserId;
    email: Text;
    passwordHash: Text;
    createdAt: Time.Time;
  };
  
  type Photo = {
    id: PhotoId;
    userId: UserId;
    url: Text;
    likes: Nat;
    views: Nat;
    createdAt: Time.Time;
    data: Blob; // Store the actual photo data
  };
  
  type Error = {
    #NotFound;
    #AlreadyExists;
    #NotAuthorized;
    #InvalidInput;
    #InternalError;
  };

  // Custom hash function for Nat to replace deprecated Hash.hash
  private func natHash(n: Nat): Nat32 {
    let hashValue = Nat32.fromNat(n % (2**32 - 1));
    return hashValue;
  };

  // Stable state for persistence across upgrades
  private stable var nextUserId : UserId = 1;
  private stable var nextPhotoId : PhotoId = 1;
  
  // Stable storage for serialization during upgrades
  private stable var usersEntries : [(UserId, User)] = [];
  private stable var userEmailEntries : [(Text, UserId)] = [];
  private stable var photosEntries : [(PhotoId, Photo)] = [];
  private stable var userPhotosEntries : [(UserId, [PhotoId])] = [];
  
  // State - runtime HashMap storage
  private var users = HashMap.HashMap<UserId, User>(10, Nat.equal, natHash);
  private var userEmailMap = HashMap.HashMap<Text, UserId>(10, Text.equal, Text.hash);
  private var photos = HashMap.HashMap<PhotoId, Photo>(100, Nat.equal, natHash);
  private var userPhotos = HashMap.HashMap<UserId, [PhotoId]>(10, Nat.equal, natHash);
  
  // System startup - recreate HashMaps from stable storage
  system func preupgrade() {
    usersEntries := Iter.toArray(users.entries());
    userEmailEntries := Iter.toArray(userEmailMap.entries());
    photosEntries := Iter.toArray(photos.entries());
    userPhotosEntries := Iter.toArray(userPhotos.entries());
  };
  
  system func postupgrade() {
    users := HashMap.fromIter<UserId, User>(usersEntries.vals(), 10, Nat.equal, natHash);
    userEmailMap := HashMap.fromIter<Text, UserId>(userEmailEntries.vals(), 10, Text.equal, Text.hash);
    photos := HashMap.fromIter<PhotoId, Photo>(photosEntries.vals(), 100, Nat.equal, natHash);
    userPhotos := HashMap.fromIter<UserId, [PhotoId]>(userPhotosEntries.vals(), 10, Nat.equal, natHash);
    
    // Clear stable storage after restoration
    usersEntries := [];
    userEmailEntries := [];
    photosEntries := [];
    userPhotosEntries := [];
  };
  
  // Better password hashing (still a placeholder - use proper crypto in production)
  private func hashPassword(password : Text) : Text {
    // In a real app, use a proper password hashing function with salt
    // This is still a placeholder, but indicates the need for proper impl
    let hashText = Text.hash(password # "salt_would_go_here");
    return Nat32.toText(hashText);
  };
  
  // User management
  public func register(email : Text, password : Text) : async Result.Result<{id: UserId}, Error> {
    // Validate inputs
    if (Text.size(email) < 3 or not Text.contains(email, #text "@")) {
      return #err(#InvalidInput);
    };
    
    if (Text.size(password) < 6) {
      return #err(#InvalidInput);
    };
    
    // Check if email already exists
    switch (userEmailMap.get(email)) {
      case (?_) { return #err(#AlreadyExists) };
      case null {
        let userId = nextUserId;
        nextUserId += 1;
        
        let newUser : User = {
          id = userId;
          email = email;
          passwordHash = hashPassword(password);
          createdAt = Time.now();
        };
        
        users.put(userId, newUser);
        userEmailMap.put(email, userId);
        userPhotos.put(userId, []);
        
        return #ok({id = userId});
      };
    };
  };
  
  public func login(email : Text, password : Text) : async Result.Result<{id: UserId}, Error> {
    switch (userEmailMap.get(email)) {
      case (?userId) {
        switch (users.get(userId)) {
          case (?userAccount) {
            if (userAccount.passwordHash == hashPassword(password)) {
              return #ok({id = userId});
            } else {
              return #err(#NotAuthorized);
            };
          };
          case null { return #err(#NotFound) };
        };
      };
      case null { return #err(#NotFound) };
    };
  };
  
  public func deleteUser(userId : UserId, password : Text) : async Result.Result<Bool, Error> {
    switch (users.get(userId)) {
      case (?userAccount) {
        if (userAccount.passwordHash == hashPassword(password)) {
          // Delete all user's photos
          switch (userPhotos.get(userId)) {
            case (?photoIds) {
              for (photoId in photoIds.vals()) {
                photos.delete(photoId);
              };
            };
            case null {};
          };
          
          // Remove user data
          userEmailMap.delete(userAccount.email);
          userPhotos.delete(userId);
          users.delete(userId);
          
          return #ok(true);
        } else {
          return #err(#NotAuthorized);
        };
      };
      case null { return #err(#NotFound) };
    };
  };
  
  // Photo management
  public func uploadPhoto(userId : UserId, photoBytes : [Nat8], mimeType : Text) : async Result.Result<{id: PhotoId}, Error> {
    // Validate inputs
    if (photoBytes.size() == 0) {
      return #err(#InvalidInput);
    };
    
    if (not Text.startsWith(mimeType, #text "image/")) {
      return #err(#InvalidInput);
    };
    
    switch (users.get(userId)) {
      case (?_) {
        let photoId = nextPhotoId;
        nextPhotoId += 1;
        
        // Create blob from byte array
        let photoBlob = Blob.fromArray(photoBytes);
        
        // Generate URL with proper extension based on mime type
        let extension = if (mimeType == "image/jpeg") {
          ".jpg";
        } else if (mimeType == "image/png") {
          ".png";
        } else if (mimeType == "image/gif") {
          ".gif";
        } else {
          ".img";
        };
        
        let url = "/photos/" # Nat.toText(photoId) # extension;
        
        let newPhoto : Photo = {
          id = photoId;
          userId = userId;
          url = url;
          likes = 0;
          views = 0;
          createdAt = Time.now();
          data = photoBlob;
        };
        
        photos.put(photoId, newPhoto);
        
        // Update user's photo list
        switch (userPhotos.get(userId)) {
          case (?userPhotoList) {
            let updatedList = Array.append<PhotoId>(userPhotoList, [photoId]);
            userPhotos.put(userId, updatedList);
          };
          case null {
            userPhotos.put(userId, [photoId]);
          };
        };
        
        return #ok({id = photoId});
      };
      case null { return #err(#NotFound) };
    };
  };
  
  public func deletePhoto(userId : UserId, photoId : PhotoId) : async Result.Result<Bool, Error> {
    switch (photos.get(photoId)) {
      case (?photo) {
        if (photo.userId != userId) {
          return #err(#NotAuthorized);
        };
        
        // Remove from photos collection
        photos.delete(photoId);
        
        // Update user's photo list
        switch (userPhotos.get(userId)) {
          case (?userPhotoList) {
            let updatedList = Array.filter<PhotoId>(userPhotoList, func(id) { id != photoId });
            userPhotos.put(userId, updatedList);
          };
          case null {};
        };
        
        return #ok(true);
      };
      case null { return #err(#NotFound) };
    };
  };
  
  public func getUserPhotos(userId : UserId) : async Result.Result<[Photo], Error> {
    switch (users.get(userId)) {
      case (?_) {
        switch (userPhotos.get(userId)) {
          case (?photoIds) {
            let photoBuffer = Buffer.Buffer<Photo>(photoIds.size());
            
            for (photoId in photoIds.vals()) {
              switch (photos.get(photoId)) {
                case (?photo) { photoBuffer.add(photo) };
                case null {};
              };
            };
            
            // Sort by creation time, newest first
            let sortedPhotos = Array.sort<Photo>(
              Buffer.toArray(photoBuffer),
              func(a, b) {
                if (a.createdAt > b.createdAt) { #less }
                else if (a.createdAt < b.createdAt) { #greater }
                else { #equal }
              }
            );
            
            return #ok(sortedPhotos);
          };
          case null { return #ok([]) };
        };
      };
      case null { return #err(#NotFound) };
    };
  };
  
  public func likePhoto(userId : UserId, photoId : PhotoId) : async Result.Result<{likes: Nat}, Error> {
    switch (users.get(userId)) {
      case (?_) {
        switch (photos.get(photoId)) {
          case (?photo) {
            let updatedPhoto : Photo = {
              id = photo.id;
              userId = photo.userId;
              url = photo.url;
              likes = photo.likes + 1;
              views = photo.views;
              createdAt = photo.createdAt;
              data = photo.data;
            };
            
            photos.put(photoId, updatedPhoto);
            return #ok({likes = updatedPhoto.likes});
          };
          case null { return #err(#NotFound) };
        };
      };
      case null { return #err(#NotFound) };
    };
  };
  
  public func viewPhoto(photoId : PhotoId) : async Result.Result<{views: Nat}, Error> {
    switch (photos.get(photoId)) {
      case (?photo) {
        let updatedPhoto : Photo = {
          id = photo.id;
          userId = photo.userId;
          url = photo.url;
          likes = photo.likes;
          views = photo.views + 1;
          createdAt = photo.createdAt;
          data = photo.data;
        };
        
        photos.put(photoId, updatedPhoto);
        return #ok({views = updatedPhoto.views});
      };
      case null { return #err(#NotFound) };
    };
  };
  
  // Get photo data - needed to actually retrieve the image
  public func getPhotoData(photoId : PhotoId) : async Result.Result<{data: Blob; mimeType: Text}, Error> {
    switch (photos.get(photoId)) {
      case (?photo) {
        // Determine mime type from URL extension
        let mimeType = if (Text.endsWith(photo.url, #text ".jpg")) {
          "image/jpeg";
        } else if (Text.endsWith(photo.url, #text ".png")) {
          "image/png";
        } else if (Text.endsWith(photo.url, #text ".gif")) {
          "image/gif";
        } else {
          "application/octet-stream";
        };
        
        return #ok({data = photo.data; mimeType = mimeType});
      };
      case null { return #err(#NotFound) };
    };
  };
  
  // Public photos for landing page
  public func getPublicPhotos() : async [Photo] {
    let allPhotos = Iter.toArray(photos.vals());
    
    // Sort by likes, then views, then most recent
    let sortedPhotos = Array.sort<Photo>(
      allPhotos,
      func(a, b) {
        if (a.likes > b.likes) { #less }
        else if (a.likes < b.likes) { #greater }
        else if (a.views > b.views) { #less }
        else if (a.views < b.views) { #greater }
        else if (a.createdAt > b.createdAt) { #less }
        else if (a.createdAt < b.createdAt) { #greater }
        else { #equal }
      }
    );
    
    // Take the top 9 photos
    let limit = if (sortedPhotos.size() > 9) { 9 } else { sortedPhotos.size() };
    let publicPhotos = Array.subArray(sortedPhotos, 0, limit);
    
    return publicPhotos;
  };
}