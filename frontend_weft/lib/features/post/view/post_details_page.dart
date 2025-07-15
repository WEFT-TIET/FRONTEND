// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../viewmodel/post_viewmodel.dart';

// class PostDetailsPage extends ConsumerStatefulWidget {
//   final String postId;
//   const PostDetailsPage({super.key, required this.postId});

//   @override
//   ConsumerState<PostDetailsPage> createState() => _PostDetailsPageState();
// }

// class _PostDetailsPageState extends ConsumerState<PostDetailsPage> {
//   final _commentController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     final postsAsync = ref.watch(postByIdProvider(widget.postId));
//     final commentsAsync = ref.watch(commentsProvider(widget.postId));

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Post Details'),
//         backgroundColor: const Color(0xFF121221),
//         foregroundColor: Colors.white,
//       ),
//       backgroundColor: const Color(0xFF121221),
//       body: postsAsync.when(
//         data: (posts) {
//           if (posts.isEmpty) {
//             return const Center(
//               child: Text(
//                 'Post not found',
//                 style: TextStyle(color: Colors.white),
//               ),
//             );
//           }

//           final post = posts.first;
//           return Column(
//             children: [
//               // Post Content
//               Container(
//                 width: double.infinity,
//                 margin: const EdgeInsets.all(16),
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF1D1D2F),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       post.title,
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'By ${post.userName}',
//                       style: const TextStyle(color: Colors.grey),
//                     ),
//                     const SizedBox(height: 12),
//                     Text(
//                       post.content,
//                       style: const TextStyle(color: Colors.white),
//                     ),
//                     const SizedBox(height: 16),
//                     Row(
//                       children: [
//                         IconButton(
//                           onPressed: () async {
//                             await ref
//                                 .read(postViewModelProvider.notifier)
//                                 .likePost(widget.postId);
//                           },
//                           icon: const Icon(
//                             Icons.favorite_border,
//                             color: Colors.red,
//                           ),
//                         ),
//                         Text(
//                           '${post.likesCount}',
//                           style: const TextStyle(color: Colors.white),
//                         ),
//                         const SizedBox(width: 16),
//                         const Icon(Icons.comment, color: Colors.grey),
//                         const SizedBox(width: 4),
//                         Text(
//                           '${post.commentsCount}',
//                           style: const TextStyle(color: Colors.white),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),

//               // Comments Section
//               Expanded(
//                 child: commentsAsync.when(
//                   data: (comments) => Column(
//                     children: [
//                       // Add Comment
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 16),
//                         child: Row(
//                           children: [
//                             Expanded(
//                               child: TextFormField(
//                                 controller: _commentController,
//                                 style: const TextStyle(color: Colors.white),
//                                 decoration: const InputDecoration(
//                                   hintText: 'Add a comment...',
//                                   hintStyle: TextStyle(color: Colors.grey),
//                                   border: OutlineInputBorder(),
//                                   focusedBorder: OutlineInputBorder(
//                                     borderSide: BorderSide(
//                                       color: Color(0xFF4A5FE4),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             IconButton(
//                               onPressed: () async {
//                                 if (_commentController.text.trim().isNotEmpty) {
//                                   final success = await ref
//                                       .read(postViewModelProvider.notifier)
//                                       .addComment(
//                                         postId: widget.postId,
//                                         content: _commentController.text.trim(),
//                                       );

//                                   if (success) {
//                                     _commentController.clear();
//                                   }
//                                 }
//                               },
//                               icon: const Icon(
//                                 Icons.send,
//                                 color: Color(0xFF4A5FE4),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),

//                       // Comments List
//                       Expanded(
//                         child: ListView.builder(
//                           padding: const EdgeInsets.all(16),
//                           itemCount: comments.length,
//                           itemBuilder: (context, index) {
//                             final comment = comments[index];
//                             return Container(
//                               margin: const EdgeInsets.only(bottom: 12),
//                               padding: const EdgeInsets.all(12),
//                               decoration: BoxDecoration(
//                                 color: const Color(0xFF1D1D2F),
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     comment.userName,
//                                     style: const TextStyle(
//                                       color: Color(0xFF4A5FE4),
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 4),
//                                   Text(
//                                     comment.content,
//                                     style: const TextStyle(color: Colors.white),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                   loading: () => const Center(
//                     child: CircularProgressIndicator(color: Color(0xFF4A5FE4)),
//                   ),
//                   error: (error, stack) => Center(
//                     child: Text(
//                       'Error loading comments: $error',
//                       style: const TextStyle(color: Colors.red),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//         loading: () => const Center(
//           child: CircularProgressIndicator(color: Color(0xFF4A5FE4)),
//         ),
//         error: (error, stack) => Center(
//           child: Text(
//             'Error: $error',
//             style: const TextStyle(color: Colors.red),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _commentController.dispose();
//     super.dispose();
//   }
// }
