import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Time "mo:base/Time";
import Nat "mo:base/Nat";
import Option "mo:base/Option";
import Error "mo:base/Error";
import Debug "mo:base/Debug";
import Types "./Types";
import Auth "./Auth";
import Gallery "./Gallery";
import Storage "./Storage";
import Payments "./Payments";

actor class Main() {
  type User = Types.User;
  type Image = Types.Image;
  type Collection = Types.Collection;
  type Payment = Types.Payment;
  type Result<T> = Types.Result<T>;
  type UserResult = Types.UserResult;
  type ImageResult = Types.ImageResult;
  type CollectionResult = Types.CollectionResult;
  type PaymentResult = Types.PaymentResult;
  
  private let storageCanister = actor("storage-canister-id"): actor {
    storeImage: (blob: Blob, contentType: Text) -> async Text;
    getImageUrl: (id: Text) -> async ?Text;
  };
  
  private let authModule = actor("auth-canister-id"): Auth.Auth;
  private let galleryModule = actor("gallery-canister-id"): Gallery.Gallery;
  private let paymentsModule = actor("payments-canister-id"): Payments.Payments;
  
  //Authentication
  
  public shared(msg) func register(username: Text, email: Text, password: Text): async UserResult {
    await authModule.register(username, email, password);
  };
  
  public shared(msg) func login(email: Text, password: Text): async UserResult {
    await authModule.login(email, password);
  };
  
  public shared(msg) func getProfile(): async UserResult {
    await authModule.getProfile();
  };
  
  public shared(msg) func updateProfile(username: ?Text): async UserResult {
    await authModule.updateProfile(username);
  };
  
  public shared(msg) func changePassword(oldPassword: Text, newPassword: Text): async UserResult {
    await authModule.changePassword(oldPassword, newPassword);
  };
  
  //Gallery
  
  public shared(msg) func addImage(
    name: Text,
    description: Text,
    contentType: Text,
    imageBlob: Blob,
    isPublic: Bool,
    tags: [Text]
  ): async ImageResult {
    await galleryModule.addImage(name, description, contentType, imageBlob, isPublic, tags);
  };
  
  public query func getImage(id: Text): async ImageResult {
    await galleryModule.getImage(id);
  };
  
  public shared(msg) func updateImage(
    id: Text,
    name: ?Text,
    description: ?Text,
    isPublic: ?Bool,
    price: ?Nat,
    tags: ?[Text]
  ): async ImageResult {
    await galleryModule.updateImage(id, name, description, isPublic, price, tags);
  };
  
  public shared(msg) func deleteImage(id: Text): async Result<Bool> {
    await galleryModule.deleteImage(id);
  };
  
  public query func getPublicImages(limit: Nat, offset: Nat): async [Image] {
    await galleryModule.getPublicImages(limit, offset);
  };
  
  public shared(msg) func getUserImages(): async [Image] {
    await galleryModule.getUserImages();
  };
  
  public shared(msg) func createCollection(
    name: Text,
    description: Text,
    isPublic: Bool
  ): async CollectionResult {
    await galleryModule.createCollection(name, description, isPublic);
  };
  
  public query func getCollection(id: Text): async CollectionResult {
    await galleryModule.getCollection(id);
  };
  
  public shared(msg) func addImageToCollection(collectionId: Text, imageId: Text): async CollectionResult {
    await galleryModule.addImageToCollection(collectionId, imageId);
  };
  
  public shared(msg) func removeImageFromCollection(collectionId: Text, imageId: Text): async CollectionResult {
    await galleryModule.removeImageFromCollection(collectionId, imageId);
  };
  
  public shared(msg) func getUserCollections(): async [Collection] {
    await galleryModule.getUserCollections();
  };
  
  public shared(msg) func setImageAsNFT(imageId: Text, price: Nat): async ImageResult {
    await galleryModule.setImageAsNFT(imageId, price);
  };
  
  //Payment Methods
  
  public shared(msg) func createDonation(
    to: Principal,
    amount: Nat,
    imageId: ?Text
  ): async PaymentResult {
    await paymentsModule.createDonation(to, amount, imageId);
  };
  
  public shared(msg) func createPurchase(
    to: Principal,
    amount: Nat,
    imageId: Text
  ): async PaymentResult {
    await paymentsModule.createPurchase(to, amount, imageId);
  };
  
  public query func getPayment(id: Text): async PaymentResult {
    await paymentsModule.getPayment(id);
  };
  
  // Get user's sent payments
  public shared(msg) func getUserPaymentsSent(): async [Payment] {
    await paymentsModule.getUserPaymentsSent();
  };
  
  public shared(msg) func getUserPaymentsReceived(): async [Payment] {
    await paymentsModule.getUserPaymentsReceived();
  };
  
  public query func getPaymentsForImage(imageId: Text): async [Payment] {
    await paymentsModule.getPaymentsForImage(imageId);
  };
  
  public shared(msg) func createNFTPurchase(
    to: Principal,
    amount: Nat,
    imageId: Text
  ): async PaymentResult {
    await paymentsModule.createNFTPurchase(to, amount, imageId);
  };
  
  public shared(msg) func getTotalEarnings(): async Nat {
    await paymentsModule.getTotalEarnings();
  };
  
  //System
  
  public query func healthCheck(): async Bool {
    true;
  };
  
  public query func version(): async Text {
    "1.0.0";
  };
  
  public query func timestamp(): async Time.Time {
    Time.now();
  };
}