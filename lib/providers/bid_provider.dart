import 'package:flutter/foundation.dart';
import '../bid_model.dart';
import '../services/bid_service.dart';

class BidProvider extends ChangeNotifier {
  List<Bid> _bids = [];
  String _selectedCategory = 'All';

  List<Bid> get bids => _bids;
  String get selectedCategory => _selectedCategory;

  List<Bid> get filteredBids {
    if (_selectedCategory == 'All') return _bids;
    return _bids.where((bid) => bid.category == _selectedCategory).toList();
  }

  void loadBids() {
    _bids = BidService.getAllBids();
    notifyListeners();
  }

  void addBid(Bid bid) {
    BidService.addBid(bid);
    _bids = BidService.getAllBids();
    notifyListeners();
  }

  void updateBid(Bid bid) {
    BidService.updateBid(bid);
    _bids = BidService.getAllBids();
    notifyListeners();
  }

  void deleteBid(String id) {
    BidService.deleteBid(id);
    _bids = BidService.getAllBids();
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }
}