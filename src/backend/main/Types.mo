import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Bool "mo:base/Bool";
import _Hash "mo:base/Hash";
import _TrieMap "mo:base/TrieMap";

module {
  public type User = {
    id: Principal;
    username: Text;
    email: Text;
    passwordHash: Text;
    createdAt: Time.Time;
    updatedAt: Time.Time;
  };

  public type Image = {
    id: Text;
    owner: Principal;
    name: Text;
    description: Text;
    url: Text;
    thumbnailUrl: Text;
    contentType: Text;
    isPublic: Bool;
    isNFT: Bool;
    price: ?Nat; // Optional price in tokens
    createdAt: Time.Time;
    updatedAt: Time.Time;
    tags: [Text];
  };

  public type Collection = {
    id: Text;
    owner: Principal;
    name: Text;
    description: Text;
    images: [Text]; // Array of image IDs
    isPublic: Bool;
    createdAt: Time.Time;
    updatedAt: Time.Time;
  };

  public type Payment = {
    id: Text;
    from: Principal;
    to: Principal;
    amount: Nat;
    imageId: ?Text; // Optional reference to an image
    timestamp: Time.Time;
    status: PaymentStatus;
    transactionType: TransactionType;
  };

  public type PaymentStatus = {
    #pending;
    #completed;
    #failed;
    #refunded;
  };

  public type TransactionType = {
    #donation;
    #purchase;
    #nftPurchase;
  };

  public type Error = {
    #NotFound;
    #AlreadyExists;
    #NotAuthorized;
    #InvalidInput;
    #InternalError;
    #LimitExceeded;
  };

  public type Result<T> = {
    #ok: T;
    #err: Error;
  };

  public type UserResult = Result<User>;
  
  public type ImageResult = Result<Image>;
  
  public type CollectionResult = Result<Collection>;
  
  public type PaymentResult = Result<Payment>;
};