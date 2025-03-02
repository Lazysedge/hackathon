import Principal "mo:base/Principal";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Option "mo:base/Option";
import Time "mo:base/Time";
import Bool "mo:base/Bool";
import TrieMap "mo:base/TrieMap";
import List "mo:base/List";
import Buffer "mo:base/Buffer";
import UUID "mo:uuid/UUID";
import Types "./Types";
import Storage "./Storage";

actor class Gallery(storageCanister: actor { 
  storeImage: (blob: Blob, contentType: Text) -> async Text;
  getImageUrl: (id: Text) -> async ?Text;
}) {
  type Image = Types.Image;
  type Collection = Types.Collection;
  type Result<T> = Types.Result<T>;
  type ImageResult = Types.ImageResult;
  type CollectionResult = Types.CollectionResult;
  type Error = Types.Error;

  private var images = TrieMap.TrieMap<Text, Image>(Text.equal, Text.hash);
  
  private var collections = TrieMap.TrieMap<Text, Collection>(Text.equal, Text.hash);
  
  private var userImages = TrieMap.TrieMap<Principal, List.List<Text>>(Principal.equal, Principal.hash);
  
  private var userCollections = TrieMap.TrieMap<Principal, List.List<Text>>(Principal.equal, Principal.hash);

  private func generateId(): Text {
    UUID.toText(await UUID.generate());
  };
  
  public shared(msg) func addImage(
    name: Text,
    description: Text,
    contentType: Text,
    imageBlob: Blob,
    isPublic: Bool,
    tags: [Text]
  ): async ImageResult {
    let caller = msg.caller;
    
    let imageUrl = await storageCanister.storeImage(imageBlob, contentType);
    let thumbnailUrl = imageUrl;
    
    let imageId = await generateId();
    let now = Time.now();
    
    let newImage: Image = {
      id = imageId;
      owner = caller;
      name = name;
      description = description;
      url = imageUrl;
      thumbnailUrl = thumbnailUrl;
      contentType = contentType;
      isPublic = isPublic;
      isNFT = false;
      price = null;
      createdAt = now;
      updatedAt = now;
      tags = tags;
    };
    
    images.put(imageId, newImage);
    
    let userImagesList = switch (userImages.get(caller)) {
      case (?list) { list };
      case (null) { List.nil<Text>() };
    };
    userImages.put(caller, List.push(imageId, userImagesList));
    
    return #ok(newImage);
  };
  
  public query func getImage(id: Text): async ImageResult {
    switch (images.get(id)) {
      case (?image) {
        return #ok(image);
      };
      case (null) {
        return #err(#NotFound);
      };
    };
  };
  
  public shared(msg) func updateImage(
    id: Text,
    name: ?Text,
    description: ?Text,
    isPublic: ?Bool,
    price: ?Nat,
    tags: ?[Text]
  ): async ImageResult {
    let caller = msg.caller;
    
    switch (images.get(id)) {
      case (?image) {
        if (Principal.notEqual(image.owner, caller)) {
          return #err(#NotAuthorized);
        };
        
        let updatedImage: Image = {
          id = image.id;
          owner = image.owner;
          name = Option.get(name, image.name);
          description = Option.get(description, image.description);
          url = image.url;
          thumbnailUrl = image.thumbnailUrl;
          contentType = image.contentType;
          isPublic = Option.get(isPublic, image.isPublic);
          isNFT = image.isNFT;
          price = Option.get(price, image.price);
          createdAt = image.createdAt;
          updatedAt = Time.now();
          tags = Option.get(tags, image.tags);
        };
        
        images.put(id, updatedImage);
        return #ok(updatedImage);
      };
      case (null) {
        return #err(#NotFound);
      };
    };
  };
  
  public shared(msg) func deleteImage(id: Text): async Result<Bool> {
    let caller = msg.caller;
    
    switch (images.get(id)) {
      case (?image) {
        if (Principal.notEqual(image.owner, caller)) {
          return #err(#NotAuthorized);
        };
        
        ignore images.remove(id);
        
        switch (userImages.get(caller)) {
          case (?list) {
            userImages.put(caller, List.filter<Text>(list, func(i) { i != id }));
          };
          case (null) { };
        };
        
        return #ok(true);
      };
      case (null) {
        return #err(#NotFound);
      };
    };
  };
  
  public query func getPublicImages(limit: Nat, offset: Nat): async [Image] {
    let publicImagesBuffer = Buffer.Buffer<Image>(0);
    
    for ((_, image) in images.entries()) {
      if (image.isPublic) {
        publicImagesBuffer.add(image);
      };
    };
    
    let totalImages = publicImagesBuffer.size();
    let start = if (offset >= totalImages) { totalImages } else { offset };
    let end = if (start + limit > totalImages) { totalImages } else { start + limit };
    
    let result = Buffer.Buffer<Image>(end - start);
    var i = start;
    while (i < end) {
      result.add(publicImagesBuffer.get(i));
      i += 1;
    };
    
    return Buffer.toArray(result);
  };
  
  public shared(msg) func getUserImages(): async [Image] {
    let caller = msg.caller;
    let userImagesBuffer = Buffer.Buffer<Image>(0);
    
    switch (userImages.get(caller)) {
      case (?list) {
        for (imageId in List.toIter(list)) {
          switch (images.get(imageId)) {
            case (?image) {
              userImagesBuffer.add(image);
            };
            case (null) { };
          };
        };
      };
      case (null) { };
    };
    
    return Buffer.toArray(userImagesBuffer);
  };
  
  public shared(msg) func createCollection(
    name: Text,
    description: Text,
    isPublic: Bool
  ): async CollectionResult {
    let caller = msg.caller;
    
    let collectionId = await generateId();
    let now = Time.now();
    
    let newCollection: Collection = {
      id = collectionId;
      owner = caller;
      name = name;
      description = description;
      images = [];
      isPublic = isPublic;
      createdAt = now;
      updatedAt = now;
    };
    
    collections.put(collectionId, newCollection);
    
    let userCollectionsList = switch (userCollections.get(caller)) {
      case (?list) { list };
      case (null) { List.nil<Text>() };
    };
    userCollections.put(caller, List.push(collectionId, userCollectionsList));
    
    return #ok(newCollection);
  };
  
  public query func getCollection(id: Text): async CollectionResult {
    switch (collections.get(id)) {
      case (?collection) {
        return #ok(collection);
      };
      case (null) {
        return #err(#NotFound);
      };
    };
  };
  
  public shared(msg) func addImageToCollection(collectionId: Text, imageId: Text): async CollectionResult {
    let caller = msg.caller;
    
    switch (collections.get(collectionId)) {
      case (?collection) {
        if (Principal.notEqual(collection.owner, caller)) {
          return #err(#NotAuthorized);
        };
        
        switch (images.get(imageId)) {
          case (?image) {
            let imageExists = Array.find<Text>(collection.images, func(id) { id == imageId });
            
            switch (imageExists) {
              case (?_) {
                return #err(#AlreadyExists);
              };
              case (null) {
                let updatedImages = Array.append<Text>(collection.images, [imageId]);
                
                let updatedCollection: Collection = {
                  id = collection.id;
                  owner = collection.owner;
                  name = collection.name;
                  description = collection.description;
                  images = updatedImages;
                  isPublic = collection.isPublic;
                  createdAt = collection.createdAt;
                  updatedAt = Time.now();
                };
                
                collections.put(collectionId, updatedCollection);
                return #ok(updatedCollection);
              };
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
  
  public shared(msg) func removeImageFromCollection(collectionId: Text, imageId: Text): async CollectionResult {
    let caller = msg.caller;
    
    switch (collections.get(collectionId)) {
      case (?collection) {
        if (Principal.notEqual(collection.owner, caller)) {
          return #err(#NotAuthorized);
        };
        
        let updatedImages = Array.filter<Text>(collection.images, func(id) { id != imageId });
        
        let updatedCollection: Collection = {
          id = collection.id;
          owner = collection.owner;
          name = collection.name;
          description = collection.description;
          images = updatedImages;
          isPublic = collection.isPublic;
          createdAt = collection.createdAt;
          updatedAt = Time.now();
        };
        
        collections.put(collectionId, updatedCollection);
        return #ok(updatedCollection);
      };
      case (null) {
        return #err(#NotFound);
      };
    };
  };
  
  public shared(msg) func getUserCollections(): async [Collection] {
    let caller = msg.caller;
    let userCollectionsBuffer = Buffer.Buffer<Collection>(0);
    
    switch (userCollections.get(caller)) {
      case (?list) {
        for (collectionId in List.toIter(list)) {
          switch (collections.get(collectionId)) {
            case (?collection) {
              userCollectionsBuffer.add(collection);
            };
            case (null) { };
          };
        };
      };
      case (null) { };
    };
    
    return Buffer.toArray(userCollectionsBuffer);
  };
  
  public shared(msg) func setImageAsNFT(imageId: Text, price: Nat): async ImageResult {
    let caller = msg.caller;
    
    switch (images.get(imageId)) {
      case (?image) {
        if (Principal.notEqual(image.owner, caller)) {
          return #err(#NotAuthorized);
        };
        
        let updatedImage: Image = {
          id = image.id;
          owner = image.owner;
          name = image.name;
          description = image.description;
          url = image.url;
          thumbnailUrl = image.thumbnailUrl;
          contentType = image.contentType;
          isPublic = image.isPublic;
          isNFT = true;
          price = ?price;
          createdAt = image.createdAt;
          updatedAt = Time.now();
          tags = image.tags;
        };
        
        images.put(imageId, updatedImage);
        return #ok(updatedImage);
      };
      case (null) {
        return #err(#NotFound);
      };
    };
  };
}