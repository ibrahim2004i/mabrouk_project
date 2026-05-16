import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:mabrouk_app/core/theme/app_theme.dart';
import 'package:mabrouk_app/core/localization/app_strings.dart';
import 'package:video_player/video_player.dart';


class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final List<Map<String, dynamic>> reels = [
    {
      "id": 1,
      "serviceId": 1,
      "serviceType": "hall",
      "providerId": 3,
      "serviceName": "قاعة الكريستال",
      "provider": "Crystal Hall",
      "caption": "أفخم قاعات الزفاف",
      "likes": 0,
      "liked": false,
      "saved": false,
      "comments": <String>[],
      "video": "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
    },
    {
      "id": 2,
      "serviceId": 2,
      "serviceType": "dress",
      "providerId": 4,
      "serviceName": "فستان ملكي",
      "provider": "Royal Dresses",
      "caption": "فساتين فاخرة بتفاصيل راقية",
      "likes": 0,
      "liked": false,
      "saved": false,
      "comments": <String>[],
      "video": "https://samplelib.com/lib/preview/mp4/sample-5s.mp4",
    },
    {
      "id": 3,
      "serviceId": 3,
      "serviceType": "cake",
      "providerId": 5,
      "serviceName": "كيك الزفاف",
      "provider": "Sweet Cake",
      "caption": "تصاميم كيك فخمة للمناسبات",
      "likes": 0,
      "liked": false,
      "saved": false,
      "comments": <String>[],
      "video": "https://samplelib.com/lib/preview/mp4/sample-10s.mp4",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final query = GoRouterState.of(context).uri.queryParameters;

    final serviceType = query['serviceType'];
    final serviceId = int.tryParse(query['serviceId'] ?? '');

    final filteredReels = serviceType != null && serviceId != null
        ? reels
            .where(
              (reel) =>
                  reel["serviceType"] == serviceType &&
                  reel["serviceId"] == serviceId,
            )
            .toList()
        : reels;

    return Scaffold(
      backgroundColor: Colors.black,
      body: filteredReels.isEmpty
          ? _emptyReelsView(context)
          : PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: filteredReels.length,
              itemBuilder: (context, index) {
                final reel = filteredReels[index];
                final comments = reel["comments"] as List<String>;

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    _VideoPlayerItem(videoUrl: reel["video"]),

                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.30),
                            Colors.transparent,
                            Colors.black.withOpacity(0.86),
                          ],
                        ),
                      ),
                    ),

                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                _circleButton(
                                  icon: Icons.arrow_back_ios_new_rounded,
                                  onTap: () => context.pop(),
                                ),
                                const Spacer(),
                                _topBadge(
                                  serviceType != null
                                      ? AppStrings.reelsServiceReels.tr
                                      : AppStrings.reelsTitle.tr,
                                ),
                              ],
                            ),
                            const Spacer(),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(child: _reelInfo(context, reel)),
                                const SizedBox(width: 12),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _actionButton(
                                      icon: reel["liked"]
                                          ? Icons.favorite_rounded
                                          : Icons.favorite_border_rounded,
                                      label: reel["likes"].toString(),
                                      color: reel["liked"]
                                          ? Colors.redAccent
                                          : AppTheme.luxuryBeige,
                                      onTap: () {
                                        setState(() {
                                          reel["liked"] = !reel["liked"];
                                          reel["likes"] +=
                                              reel["liked"] ? 1 : -1;
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    _actionButton(
                                      icon: Icons.mode_comment_outlined,
                                      label: comments.length.toString(),
                                      color: AppTheme.luxuryBeige,
                                      onTap: () => _showComments(context, reel),
                                    ),
                                    const SizedBox(height: 16),
                                    _actionButton(
                                      icon: Icons.send_rounded,
                                      label: AppStrings.reelsShare.tr,
                                      color: AppTheme.luxuryBeige,
                                      onTap: () => _showComingSoonSnackBar(
                                        context,
                                        AppStrings.reelsShareSoon.tr,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    _saveButton(reel),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _topBadge(String title) {
    const beige = AppTheme.luxuryBeige;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.34),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: beige.withOpacity(0.18)),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: beige,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _emptyReelsView(BuildContext context) {
    const maroon = AppTheme.primaryMaroon;
    const beige = AppTheme.luxuryBeige;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: _circleButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => context.pop(),
              ),
            ),
            Center(
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: beige,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: maroon.withOpacity(0.12)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.video_library_outlined,
                      color: maroon,
                      size: 46,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      AppStrings.reelsNoReels.tr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: maroon,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.reelsNoReelsSubtitle.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: maroon.withOpacity(0.62),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _saveButton(Map<String, dynamic> reel) {
    const maroon = AppTheme.primaryMaroon;
    const beige = AppTheme.luxuryBeige;

    return GestureDetector(
      onTap: () {
        setState(() {
          reel["saved"] = !reel["saved"];
        });
      },
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: reel["saved"]
                  ? maroon.withOpacity(0.92)
                  : Colors.black.withOpacity(0.34),
              border: Border.all(
                color: reel["saved"]
                    ? beige.withOpacity(0.75)
                    : beige.withOpacity(0.16),
                width: 1.2,
              ),
              boxShadow: reel["saved"]
                  ? [
                      BoxShadow(
                        color: maroon.withOpacity(0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : [],
            ),
            child: Icon(
              reel["saved"]
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color: beige,
              size: 22,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            reel["saved"] ? AppStrings.reelsSaved.tr : AppStrings.save.tr,
            style: TextStyle(
              color: beige.withOpacity(0.92),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _reelInfo(BuildContext context, Map<String, dynamic> reel) {
    const maroon = AppTheme.primaryMaroon;
    const beige = AppTheme.luxuryBeige;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            context.push(
              '/customer/services/${reel["serviceType"]}/${reel["serviceId"]}',
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: maroon.withOpacity(0.88),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: beige.withOpacity(0.18)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.open_in_new_rounded, color: beige, size: 15),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    reel["serviceName"],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: beige,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          reel["provider"],
          style: TextStyle(
            color: beige.withOpacity(0.9),
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          reel["caption"],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
            height: 1.45,
          ),
        ),
      ],
    );
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    const beige = AppTheme.luxuryBeige;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          shape: BoxShape.circle,
          border: Border.all(color: beige.withOpacity(0.22)),
        ),
        child: Icon(icon, color: beige, size: 17),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    const beige = AppTheme.luxuryBeige;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.34),
              shape: BoxShape.circle,
              border: Border.all(color: beige.withOpacity(0.16)),
            ),
            child: Icon(icon, color: color, size: 23),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              color: beige,
              fontWeight: FontWeight.w800,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  void _showComments(BuildContext context, Map<String, dynamic> reel) {
    final controller = TextEditingController();
    const maroon = AppTheme.primaryMaroon;
    const beige = AppTheme.luxuryBeige;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final comments = reel["comments"] as List<String>;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.62,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                decoration: const BoxDecoration(
                  color: beige,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: maroon.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      AppStrings.reelsComments.tr,
                      style: const TextStyle(
                        color: maroon,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: comments.isEmpty
                          ? Center(
                              child: Text(
                                AppStrings.reelsCommentsSoon.tr,
                                style: TextStyle(
                                  color: maroon.withOpacity(0.55),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: comments.length,
                              itemBuilder: (context, i) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.72),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: maroon.withOpacity(0.08),
                                    ),
                                  ),
                                  child: Text(
                                    comments[i],
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      color: maroon,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller,
                            textAlign: TextAlign.right,
                            decoration: InputDecoration(
                              hintText: AppStrings.reelsWriteComment.tr,
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.76),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () {
                            final text = controller.text.trim();
                            if (text.isEmpty) return;

                            setState(() {
                              comments.add(text);
                            });

                            setSheetState(() {});
                            controller.clear();
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: maroon,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.send_rounded,
                              color: beige,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(controller.dispose);
  }

  void _showComingSoonSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.primaryMaroon,
        elevation: 10,
        margin: const EdgeInsets.all(14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        content: Text(
          message,
          style: const TextStyle(
            color: AppTheme.luxuryBeige,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _VideoPlayerItem extends StatefulWidget {
  final String videoUrl;

  const _VideoPlayerItem({
    required this.videoUrl,
  });

  @override
  State<_VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<_VideoPlayerItem> {
  late final VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    )
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        _controller
          ..setLooping(true)
          ..setVolume(1)
          ..play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(
          child: CircularProgressIndicator(
            color: AppTheme.luxuryBeige,
          ),
        ),
      );
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _controller.value.size.width,
          height: _controller.value.size.height,
          child: VideoPlayer(_controller),
        ),
      ),
    );
  }
}