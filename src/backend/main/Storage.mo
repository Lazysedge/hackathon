import Text "mo:base/Text";
import Blob "mo:base/Blob";
import Array "mo:base/Array";
import Nat "mo:base/Nat";
import Nat8 "mo:base/Nat8";
import TrieMap "mo:base/TrieMap";
import Time "mo:base/Time";
import Option "mo:base/Option";
import UUID "mo:uuid/UUID";
import Debug "mo:base/Debug";
import Types "./Types";

actor class Storage() {
  type Result<T> = Types.Result<T>;
  
  private var assets = TrieMap.TrieMap<Text, Blob>(Text.equal, Text.hash);
  
  private var assetMetadata = TrieMap.TrieMap<Text, AssetMetadata>(Text.equal, Text.hash);
  
  private type AssetMetadata = {
    contentType: Text;
    createdAt: Time.Time;
    size: Nat;
  };
  
  private let MAX_ASSET_SIZE = 10 * 1024 * 1024;
  
  private let URL_PREFIX = "https://example.com/assets/";
  
  private func generateId(): async Text {
    UUID.toText(await UUID.generate());
  };
  
  public func storeImage(blob: Blob, contentType: Text): async Text {
    let assetId = await generateId();
    
    let size = blob.size();
    
    if (size > MAX_ASSET_SIZE) {
      Debug.trap("Asset is too large");
    };
    
    assets.put(assetId, blob);
    assetMetadata.put(assetId, {
      contentType = contentType;
      createdAt = Time.now();
      size = size;
    });
    
    return assetId;
  };
  
  public query func getAsset(id: Text): async ?Blob {
    assets.get(id);
  };
  
  public query func getAssetMetadata(id: Text): async ?AssetMetadata {
    assetMetadata.get(id);
  };
  
  public func getImageUrl(id: Text): async ?Text {
    switch (assets.get(id)) {
      case (?_) {
        return ?("https://raw.ic0.app/asset/" # id);
      };
      case (null) {
        return null;
      };
    };
  };
  
  public func deleteAsset(id: Text): async Bool {
    switch (assets.get(id)) {
      case (?_) {
        ignore assets.remove(id);
        ignore assetMetadata.remove(id);
        return true;
      };
      case (null) {
        return false;
      };
    };
  };
  
  public query func getAssetCount(): async Nat {
    assets.size();
  };
  
  public query func getTotalStorageUsed(): async Nat {
    var total: Nat = 0;
    for ((_, metadata) in assetMetadata.entries()) {
      total += metadata.size;
    };
    return total;
  };
}