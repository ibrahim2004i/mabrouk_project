import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:mabrouk_app/core/localization/app_strings.dart';
import 'package:mabrouk_app/core/theme/app_theme.dart';
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
      "caption": "أفخم قاعات الزفاف بتفاصيل ملكية وأجواء سينمائية.",
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
      "caption": "فساتين فاخرة بتفاصيل راقية للمناسبات.",
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
      "caption": "تصاميم كيك فخمة للمناسبات والأفراح.",
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

                    const _LuxuryOverlay(),

                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
                        child: Column(
                          children: [
                            _topBar(
                              context: context,
                              title: serviceType != null
                                  ? AppStrings.reelsServiceReels.tr
                                  : AppStrings.reelsTitle.tr,
                            ),
                            const Spacer(),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(child: _reelInfo(context, reel)),
                                const SizedBox(width: 12),
                                _actionsColumn(
                                  reel: reel,
                                  comments: comments,
                                  context: context,
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

  Widget _topBar({
    required BuildContext context,
    required String title,
  }) {
    return Row(
      children: [
        _circleButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: () => context.pop(),
        ),
        const Spacer(),
        _topBadge(title),
      ],
    );
  }

  Widget _actionsColumn({
    required Map<String, dynamic> reel,
    required List<String> comments,
    required BuildContext context,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _actionButton(
          icon: reel["liked"]
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
          label: reel["likes"].toString(),
          color: reel["liked"] ? Colors.redAccent : AppTheme.luxuryBeige,
          active: reel["liked"] == true,
          onTap: () {
            setState(() {
              reel["liked"] = !reel["liked"];
              reel["likes"] += reel["liked"] ? 1 : -1;
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
    );
  }

  Widget _topBadge(String title) {
    const beige = AppTheme.luxuryBeige;
    const maroon = AppTheme.primaryMaroon;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: maroon.withOpacity(0.72),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: beige.withOpacity(0.24)),
        boxShadow: [
          BoxShadow(
            color: maroon.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: beige,
          fontWeight: FontWeight.w900,
          fontSize: 12,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _emptyReelsView(BuildContext context) {
    const maroon = AppTheme.primaryMaroon;
    const beige = AppTheme.luxuryBeige;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            maroon,
            Color(0xFF250000),
            Colors.black,
          ],
        ),
      ),
      child: SafeArea(
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
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: beige,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: maroon.withOpacity(0.12)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: maroon.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.video_library_outlined,
                          color: maroon,
                          size: 42,
                        ),
                      ),
                      const SizedBox(height: 16),
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
      ),
    );
  }

  Widget _saveButton(Map<String, dynamic> reel) {
    const maroon = AppTheme.primaryMaroon;
    const beige = AppTheme.luxuryBeige;
    final saved = reel["saved"] == true;

    return GestureDetector(
      onTap: () {
        setState(() {
          reel["saved"] = !saved;
        });
      },
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: saved ? beige : Colors.black.withOpacity(0.36),
              border: Border.all(
                color: saved ? maroon.withOpacity(0.35) : beige.withOpacity(0.18),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: saved
                      ? beige.withOpacity(0.28)
                      : Colors.black.withOpacity(0.18),
                  blurRadius: 16,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Icon(
              saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: saved ? maroon : beige,
              size: 23,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            saved ? AppStrings.reelsSaved.tr : AppStrings.save.tr,
            style: TextStyle(
              color: beige.withOpacity(0.95),
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _reelInfo(BuildContext context, Map<String, dynamic> reel) {
    const maroon = AppTheme.primaryMaroon;
    const beige = AppTheme.luxuryBeige;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.28),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: beige.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: Get.locale?.languageCode == 'ar'
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              context.push(
                '/customer/services/${reel["serviceType"]}/${reel["serviceId"]}',
              );
            },
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: maroon.withOpacity(0.90),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: beige.withOpacity(0.22)),
                boxShadow: [
                  BoxShadow(
                    color: maroon.withOpacity(0.28),
                    blurRadius: 14,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.open_in_new_rounded, color: beige, size: 15),
                  const SizedBox(width: 7),
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
          const SizedBox(height: 11),
          Text(
            reel["provider"],
            textAlign:
                Get.locale?.languageCode == 'ar' ? TextAlign.right : TextAlign.left,
            style: TextStyle(
              color: beige.withOpacity(0.92),
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            reel["caption"],
            textAlign:
                Get.locale?.languageCode == 'ar' ? TextAlign.right : TextAlign.left,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
              height: 1.45,
            ),
          ),
        ],
      ),
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
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.38),
          shape: BoxShape.circle,
          border: Border.all(color: beige.withOpacity(0.25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.22),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(icon, color: beige, size: 17),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    bool active = false,
    VoidCallback? onTap,
  }) {
    const beige = AppTheme.luxuryBeige;
    const maroon = AppTheme.primaryMaroon;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: active ? beige : Colors.black.withOpacity(0.36),
              shape: BoxShape.circle,
              border: Border.all(
                color: active ? beige.withOpacity(0.65) : beige.withOpacity(0.18),
              ),
              boxShadow: [
                BoxShadow(
                  color: active
                      ? beige.withOpacity(0.28)
                      : Colors.black.withOpacity(0.20),
                  blurRadius: 15,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: active ? maroon : color,
              size: 23,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              color: beige,
              fontWeight: FontWeight.w900,
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
                height: MediaQuery.of(context).size.height * 0.64,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                decoration: const BoxDecoration(
                  color: beige,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 44,
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
                                    textAlign: Get.locale?.languageCode == 'ar'
                                        ? TextAlign.right
                                        : TextAlign.left,
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
                            textAlign: Get.locale?.languageCode == 'ar'
                                ? TextAlign.right
                                : TextAlign.left,
                            decoration: InputDecoration(
                              hintText: AppStrings.reelsWriteComment.tr,
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.78),
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
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: maroon,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: maroon.withOpacity(0.24),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
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

class _LuxuryOverlay extends StatelessWidget {
  const _LuxuryOverlay();

  @override
  Widget build(BuildContext context) {
    const maroon = AppTheme.primaryMaroon;

    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              maroon.withOpacity(0.50),
              Colors.black.withOpacity(0.10),
              Colors.transparent,
              Colors.black.withOpacity(0.82),
            ],
            stops: const [0.0, 0.24, 0.48, 1.0],
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
  bool _isMuted = false;
  bool _isPlaying = true;

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

  void _togglePlay() {
    if (!_controller.value.isInitialized) return;

    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
      }
    });
  }

  void _toggleMute() {
    if (!_controller.value.isInitialized) return;

    setState(() {
      _isMuted = !_isMuted;
      _controller.setVolume(_isMuted ? 0 : 1);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const beige = AppTheme.luxuryBeige;

    if (!_controller.value.isInitialized) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(
          child: CircularProgressIndicator(color: beige),
        ),
      );
    }

    return GestureDetector(
  onTap: _togglePlay,
  onLongPress: _toggleMute,
  child: SizedBox.expand(
    child: Stack(
      fit: StackFit.expand,
      children: [
        FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _controller.value.size.width,
            height: _controller.value.size.height,
            child: VideoPlayer(_controller),
          ),
        ),
        if (!_isPlaying)
          Center(
            child: Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
                shape: BoxShape.circle,
                border: Border.all(color: beige.withOpacity(0.22)),
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: beige,
                size: 50,
              ),
            ),
          ),
        Positioned(
          left: 14,
          bottom: 14,
          child: AnimatedOpacity(
            opacity: _isMuted ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.38),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: beige.withOpacity(0.18)),
              ),
              child: const Icon(
                Icons.volume_off_rounded,
                color: beige,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    ),
  ),
);
  }
}