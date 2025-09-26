import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

final List<Map<String, dynamic>> _mediaPosts = [
  {
    'id': 'post1', 'type': 'image', 'isGallery': true, 'imagePath': 'assets/images/post 1.jpg', 'isDummy': true, 'likes': 1203, 'imageCount': 5, 'caption': 'Just finished an amazing training session! 💪', 'username': 'John Doe', 'handle': '@johndoe', 'avatarUrl': 'assets/images/current_user.jpg', 'comments': 88, 'retweets': 45
  },
  {
    'id': 'post2', 'type': 'video', 'isGallery': false, 'filePath': 'assets/videos/video.mp4', 'thumbnailPath': 'assets/images/post 2.jpg', 'isDummy': true, 'likes': 856, 'caption': 'Performance analysis session', 'username': 'John Doe', 'handle': '@johndoe', 'avatarUrl': 'assets/images/current_user.jpg', 'comments': 54, 'retweets': 23
  },
  {
    'id': 'post3', 'type': 'image', 'isGallery': false, 'imagePath': 'assets/images/post 3.jpg', 'isDummy': true, 'likes': 2400, 'caption': 'Pool training session complete', 'username': 'John Doe', 'handle': '@johndoe', 'avatarUrl': 'assets/images/current_user.jpg', 'comments': 152, 'retweets': 99
  },
  {
    'id': 'post4', 'type': 'image', 'isGallery': false, 'imagePath': 'assets/images/basketball.jpg', 'isDummy': true, 'likes': 734, 'caption': 'Basketball practice today', 'username': 'John Doe', 'handle': '@johndoe', 'avatarUrl': 'assets/images/current_user.jpg', 'comments': 32, 'retweets': 12
  },
  {
    'id': 'post5', 'type': 'image', 'isGallery': true, 'imagePath': 'assets/images/football.jpg', 'isDummy': true, 'likes': 1500, 'imageCount': 3, 'caption': 'Football training with the team', 'username': 'John Doe', 'handle': '@johndoe', 'avatarUrl': 'assets/images/current_user.jpg', 'comments': 110, 'retweets': 60
  },
];

class ProfilePostSection extends StatelessWidget {
  final Function(Map<String, dynamic>)? onPostTap;
  
  const ProfilePostSection({super.key, this.onPostTap});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            indicatorColor: Colors.blueAccent,
            labelColor: Colors.blueAccent,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(icon: Icon(Icons.grid_on_outlined)),
              Tab(icon: Icon(Icons.list_alt_outlined)),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildInstagramGrid(context),
                _buildTwitterList(context),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildInstagramGrid(BuildContext context) {
  if (_mediaPosts.isEmpty) {
    return Center(child: Text("No posts yet."));
  }

  return StaggeredGrid.count(
    crossAxisCount: 3,
    mainAxisSpacing: 2,
    crossAxisSpacing: 2,
    children: _mediaPosts.asMap().entries.map((entry) {
      int index = entry.key;
      Map<String, dynamic> media = entry.value;

      final patterns = [
        {'crossAxis': 1, 'mainAxis': 1},
        {'crossAxis': 1, 'mainAxis': 1},
        {'crossAxis': 2, 'mainAxis': 2},
        {'crossAxis': 1, 'mainAxis': 1},
        {'crossAxis': 1, 'mainAxis': 1},
      ];

      final tilePattern = patterns[index % patterns.length];
      return StaggeredGridTile.count(
        crossAxisCellCount: tilePattern['crossAxis']!,
        mainAxisCellCount: tilePattern['mainAxis']!,
        child: _buildInstagramGridItem(media, context),
      );
    }).toList(),
  );
}

Widget _buildInstagramGridItem(Map<String, dynamic> media, BuildContext context) {
  final bool isVideo = media['type'] == 'video';
  final bool isGallery = media['isGallery'] == true;
  final String imagePath = isVideo ? media['thumbnailPath'] : media['imagePath'];

  return GestureDetector(
    onTap: () {
      final profilePostSection = context.findAncestorWidgetOfExactType<ProfilePostSection>();
      if (profilePostSection?.onPostTap != null) {
        profilePostSection!.onPostTap!(media);
      }
    },
    child: Hero(
      tag: 'post_${media['id']}',
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.broken_image, color: Colors.grey[400]),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: isVideo
                  ? Icon(Icons.videocam, color: Colors.white, size: 20)
                  : (isGallery
                      ? Icon(Icons.collections, color: Colors.white, size: 20)
                      : const SizedBox.shrink()),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildTwitterList(BuildContext context) {
  return ListView.separated(
    itemCount: _mediaPosts.length,
    itemBuilder: (context, index) {
      return GestureDetector(
        onTap: () {
          final profilePostSection = context.findAncestorWidgetOfExactType<ProfilePostSection>();
          if (profilePostSection?.onPostTap != null) {
            profilePostSection!.onPostTap!(_mediaPosts[index]);
          }
        },
        child: _buildTwitterPostItem(_mediaPosts[index], context),
      );
    },
    separatorBuilder: (context, index) => Divider(height: 1, thickness: 1, color: Colors.grey[200]),
  );
}

Widget _buildTwitterPostItem(Map<String, dynamic> media, BuildContext context) {
  final bool isVideo = media['type'] == 'video';
  final String imagePath = isVideo ? media['thumbnailPath'] : media['imagePath'];

  return Container(
    color: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundImage: AssetImage(media['avatarUrl']),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(media['username'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(width: 4),
                  Text(media['handle'], style: TextStyle(color: Colors.grey[600], fontSize: 15)),
                  const Spacer(),
                  Icon(Icons.more_horiz, color: Colors.grey[600]),
                ],
              ),
              const SizedBox(height: 4),
              Text(media['caption'], style: const TextStyle(fontSize: 15, height: 1.3)),
              const SizedBox(height: 12),
              if (imagePath.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(height: 200, color: Colors.grey[200], child: Icon(Icons.image_not_supported)),
                      ),
                      if (isVideo)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), shape: BoxShape.circle),
                          child: const Icon(Icons.play_arrow, color: Colors.white, size: 32),
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTweetAction(Icons.chat_bubble_outline, '${media['comments']}'),
                  _buildTweetAction(Icons.repeat, '${media['retweets']}'),
                  _buildTweetAction(Icons.favorite_border, '${media['likes']}'),
                  _buildTweetAction(Icons.ios_share_outlined, ''),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildTweetAction(IconData icon, String text) {
  return Row(
    children: [
      Icon(icon, size: 18, color: Colors.grey[600]),
      const SizedBox(width: 4),
      Text(text, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
    ],
  );
}

