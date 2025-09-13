import 'package:flutter/material.dart';
import 'bid_model.dart';
import 'bid_card.dart';

class BidListScreen extends StatelessWidget {
  const BidListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sampleBids = _generateSampleBids();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sports Bids'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: sampleBids.length,
        itemBuilder: (context, index) {
          return BidCard(
            bid: sampleBids[index],
            onTap: () => _showBidDetails(context, sampleBids[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateBidDialog(context),
        backgroundColor: Colors.blue[600],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  List<Bid> _generateSampleBids() {
    return [
      Bid(
        id: '1',
        title: 'Basketball Tournament Entry',
        description: 'Looking for a team to join the city basketball tournament. Great opportunity for exposure.',
        amount: 250.0,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        status: 'active',
        category: 'Basketball',
        expiresAt: DateTime.now().add(const Duration(days: 7)),
      ),
      Bid(
        id: '2',
        title: 'Soccer Equipment Sponsorship',
        description: 'Need sponsorship for new soccer equipment for our youth team.',
        amount: 500.0,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        status: 'pending',
        category: 'Soccer',
      ),
      Bid(
        id: '3',
        title: 'Tennis Court Booking',
        description: 'Premium tennis court booking for weekend matches.',
        amount: 150.0,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        status: 'completed',
        category: 'Tennis',
      ),
    ];
  }

  void _showBidDetails(BuildContext context, Bid bid) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                bid.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                bid.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(Icons.attach_money, color: Colors.green[700]),
                  Text(
                    '\$${bid.amount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateBidDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Bid'),
        content: const Text('Bid creation form would go here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}