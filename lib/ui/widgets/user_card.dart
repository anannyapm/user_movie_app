import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sample_project/core/models/user_models.dart';
import 'package:sample_project/ui/views/movie_list_view.dart';

class UserCard extends StatelessWidget {
  const UserCard({
    super.key,
    required this.user,
  });

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: user.avatar.isEmpty
              ? Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[200],
                  child: const Icon(Icons.person, size: 26, color: Colors.grey),
                )
              : CachedNetworkImage(
                  imageUrl: user.avatar,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[200],
                    child:
                        const Icon(Icons.person, size: 26, color: Colors.grey),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[200],
                    child: const Icon(Icons.error, size: 26, color: Colors.red),
                  ),
                ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user.id != null)
              Text(
                '#${user.id} ',
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            Text(
              '${user.firstName} ${user.lastName}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        subtitle: Text(
          user.job ?? '',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MovieListScreen()),
        ),
      ),
    );
  }
}
