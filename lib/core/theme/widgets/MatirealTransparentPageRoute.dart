// // import 'package:flutter/material.dart';
// // import 'package:better_player_plus/better_player_plus.dart';
// //
// // void main() {
// //   runApp(MyApp());
// // }
// //
// // class MyApp extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: "Better Player Demo",
// //       home: VideoScreen(),
// //       debugShowCheckedModeBanner: false,
// //     );
// //   }
// }
//
// class VideoScreen extends StatefulWidget {
//   @override
//   _VideoScreenState createState() => _VideoScreenState();
// }
//
// class _VideoScreenState extends State<VideoScreen> {
//   late BetterPlayerController _betterPlayerController;
//
//   @override
//   void initState() {
//     super.initState();
//
//     BetterPlayerDataSource dataSource = BetterPlayerDataSource(
//       BetterPlayerDataSourceType.network,
//       "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8", // لينك الفيديو
//       // لو عندك MP4 جرب: "https://www.example.com/video.mp4"
//     );
//
//     _betterPlayerController = BetterPlayerController(
//       BetterPlayerConfiguration(
//         aspectRatio: 16 / 9,
//         autoPlay: true,
//         looping: false,
//       ),
//       betterPlayerDataSource: dataSource,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Demo Better Player")),
//       body: Center(
//         child: BetterPlayer(
//           controller: _betterPlayerController,
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _betterPlayerController.dispose();
//     super.dispose();
//   }
// }
