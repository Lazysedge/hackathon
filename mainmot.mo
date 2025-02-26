// backend/main.mo
import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Blob "mo:base/Blob";
import HashMap "mo:base/HashMap";
import Hash "mo:base/Hash";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Principal "mo:base/Principal";
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
    };
    
    type Error = {
    #NotFound;
    #AlreadyExists;
    #NotAuthorized;
    #InvalidInput;
    #InternalError;
    };

  // State
    private stable var nextUserId : UserId = 1;
    private stable var nextPhotoId : PhotoId = 1;
    
    private let users = HashMap.HashMap<UserId, User>(10, Nat.equal, Hash.hash);
    private let userEmailMap = HashMap.HashMap<Text, UserId>(10, Text.equal, Text.hash);
    private let photos = HashMap.HashMap<PhotoId, Photo>(100, Nat.equal, Hash.hash);
    private let userPhotos = HashMap.HashMap<UserId, [PhotoId]>(10, Nat.equal, Hash.hash);
    
  // Simple password hashing (in a real app, use proper cryptographic functions)
    private func hashPassword(password : Text) : Text {
    // This is a placeholder for a proper hashing function
    return password # "_hashed";
    };
    
  // User management
    public func register(email : Text, password : Text) : async Result.Result<{id: UserId}, Error> {
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
            case (?user) {
            if (user.passwordHash == hashPassword(password)) {
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
    
  // Photo management
    public func uploadPhoto(userId : UserId, photoBytes : [Nat8], mimeType : Text) : async Result.Result<{id: PhotoId}, Error> {
    switch (users.get(userId)) {
        case (?user) {
        let photoId = nextPhotoId;
        nextPhotoId += 1;
        
        // In a real app, you'd store the photo data in a blob store or asset canister
        // Here we're just simulating the URL generation
        let url = "/photos/" # Nat.toText(photoId) # ".jpg";
        
        let newPhoto : Photo = {
            id = photoId;
            userId = userId;
            url = url;
            likes = 0;
            views = 0;
            createdAt = Time.now();
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
            
            return #ok(Buffer.toArray(photoBuffer));
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
        };
        
        photos.put(photoId, updatedPhoto);
        return #ok({views = updatedPhoto.views});
        };
        case null { return #err(#NotFound) };
    };
    };
    
  // Public photos for landing page
    public func getPublicPhotos() : async [Photo] {
    let publicPhotoBuffer = Buffer.Buffer<Photo>(10);
    var count = 0;
    
    for ((_, photo) in photos.entries()) {
      if (count < 9) {  // Limit to 9 photos for the landing page
        publicPhotoBuffer.add(photo);
        count += 1;
        } else {
        break;
        };
    };
    
    return Buffer.toArray(publicPhotoBuffer);
    };
}