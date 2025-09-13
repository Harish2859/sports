import '../bid_model.dart';

class BidService {
  static final List<Bid> _bids = [];

  static List<Bid> getAllBids() => List.from(_bids);

  static void addBid(Bid bid) => _bids.add(bid);

  static void updateBid(Bid updatedBid) {
    final index = _bids.indexWhere((bid) => bid.id == updatedBid.id);
    if (index != -1) _bids[index] = updatedBid;
  }

  static void deleteBid(String id) => _bids.removeWhere((bid) => bid.id == id);

  static List<Bid> getBidsByStatus(String status) =>
      _bids.where((bid) => bid.status == status).toList();

  static List<Bid> getBidsByCategory(String category) =>
      _bids.where((bid) => bid.category == category).toList();
}