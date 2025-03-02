import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Time "mo:base/Time";
import Nat "mo:base/Nat";
import Option "mo:base/Option";
import Array "mo:base/Array";
import TrieMap "mo:base/TrieMap";
import List "mo:base/List";
import Buffer "mo:base/Buffer";
import UUID "mo:uuid/UUID";
import Types "./Types";

actor class Payments() {
  type Payment = Types.Payment;
  type PaymentStatus = Types.PaymentStatus;
  type TransactionType = Types.TransactionType;
  type Result<T> = Types.Result<T>;
  type PaymentResult = Types.PaymentResult;
  type Error = Types.Error;
  
  private var payments = TrieMap.TrieMap<Text, Payment>(Text.equal, Text.hash);
  
  private var userPaymentsSent = TrieMap.TrieMap<Principal, List.List<Text>>(Principal.equal, Principal.hash);
  private var userPaymentsReceived = TrieMap.TrieMap<Principal, List.List<Text>>(Principal.equal, Principal.hash);
  
  private func generateId(): async Text {
    UUID.toText(await UUID.generate());
  };
  
  public shared(msg) func createDonation(
    to: Principal,
    amount: Nat,
    imageId: ?Text
  ): async PaymentResult {
    let caller = msg.caller;
    
    let paymentId = await generateId();
    let now = Time.now();
    
    let newPayment: Payment = {
      id = paymentId;
      from = caller;
      to = to;
      amount = amount;
      imageId = imageId;
      timestamp = now;
      status = #completed;
      transactionType = #donation;
    };
    
    payments.put(paymentId, newPayment);
    
    let sentPayments = switch (userPaymentsSent.get(caller)) {
      case (?list) { list };
      case (null) { List.nil<Text>() };
    };
    userPaymentsSent.put(caller, List.push(paymentId, sentPayments));
    
    let receivedPayments = switch (userPaymentsReceived.get(to)) {
      case (?list) { list };
      case (null) { List.nil<Text>() };
    };
    userPaymentsReceived.put(to, List.push(paymentId, receivedPayments));
    
    return #ok(newPayment);
  };
  
  public shared(msg) func createPurchase(
    to: Principal,
    amount: Nat,
    imageId: Text
  ): async PaymentResult {
    let caller = msg.caller;
    
    let paymentId = await generateId();
    let now = Time.now();
    
    let newPayment: Payment = {
      id = paymentId;
      from = caller;
      to = to;
      amount = amount;
      imageId = ?imageId;
      timestamp = now;
      status = #completed;
      transactionType = #purchase;
    };
    
    payments.put(paymentId, newPayment);
    
    let sentPayments = switch (userPaymentsSent.get(caller)) {
      case (?list) { list };
      case (null) { List.nil<Text>() };
    };
    userPaymentsSent.put(caller, List.push(paymentId, sentPayments));
    
    let receivedPayments = switch (userPaymentsReceived.get(to)) {
      case (?list) { list };
      case (null) { List.nil<Text>() };
    };
    userPaymentsReceived.put(to, List.push(paymentId, receivedPayments));
    
    return #ok(newPayment);
  };
  
  public query func getPayment(id: Text): async PaymentResult {
    switch (payments.get(id)) {
      case (?payment) {
        return #ok(payment);
      };
      case (null) {
        return #err(#NotFound);
      };
    };
  };
  
  public shared(msg) func getUserPaymentsSent(): async [Payment] {
    let caller = msg.caller;
    let userPaymentsBuffer = Buffer.Buffer<Payment>(0);
    
    switch (userPaymentsSent.get(caller)) {
      case (?list) {
        for (paymentId in List.toIter(list)) {
          switch (payments.get(paymentId)) {
            case (?payment) {
              userPaymentsBuffer.add(payment);
            };
            case (null) { };
          };
        };
      };
      case (null) { };
    };
    
    return Buffer.toArray(userPaymentsBuffer);
  };
  
  public shared(msg) func getUserPaymentsReceived(): async [Payment] {
    let caller = msg.caller;
    let userPaymentsBuffer = Buffer.Buffer<Payment>(0);
    
    switch (userPaymentsReceived.get(caller)) {
      case (?list) {
        for (paymentId in List.toIter(list)) {
          switch (payments.get(paymentId)) {
            case (?payment) {
              userPaymentsBuffer.add(payment);
            };
            case (null) { };
          };
        };
      };
      case (null) { };
    };
    
    return Buffer.toArray(userPaymentsBuffer);
  };
  
  public query func getPaymentsForImage(imageId: Text): async [Payment] {
    let imagePaymentsBuffer = Buffer.Buffer<Payment>(0);
    
    for ((_, payment) in payments.entries()) {
      switch (payment.imageId) {
        case (?id) {
          if (id == imageId) {
            imagePaymentsBuffer.add(payment);
          };
        };
        case (null) { };
      };
    };
    
    return Buffer.toArray(imagePaymentsBuffer);
  };
  
  public shared(msg) func createNFTPurchase(
    to: Principal,
    amount: Nat,
    imageId: Text
  ): async PaymentResult {
    let caller = msg.caller;
    
    let paymentId = await generateId();
    let now = Time.now();
    
    let newPayment: Payment = {
      id = paymentId;
      from = caller;
      to = to;
      amount = amount;
      imageId = ?imageId;
      timestamp = now;
      status = #completed;
      transactionType = #nftPurchase;
    };
    
    payments.put(paymentId, newPayment);
    
    let sentPayments = switch (userPaymentsSent.get(caller)) {
      case (?list) { list };
      case (null) { List.nil<Text>() };
    };
    userPaymentsSent.put(caller, List.push(paymentId, sentPayments));
    
    let receivedPayments = switch (userPaymentsReceived.get(to)) {
      case (?list) { list };
      case (null) { List.nil<Text>() };
    };
    userPaymentsReceived.put(to, List.push(paymentId, receivedPayments));
    
    return #ok(newPayment);
  };
  
  public shared(msg) func getTotalEarnings(): async Nat {
    let caller = msg.caller;
    var total: Nat = 0;
    
    switch (userPaymentsReceived.get(caller)) {
      case (?list) {
        for (paymentId in List.toIter(list)) {
          switch (payments.get(paymentId)) {
            case (?payment) {
              total += payment.amount;
            };
            case (null) { };
          };
        };
      };
      case (null) { };
    };
    
    return total;
  };
}