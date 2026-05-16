import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';

import 'package:mabrouk_app/core/localization/app_strings.dart';
import 'package:mabrouk_app/core/theme/app_theme.dart';
import 'package:mabrouk_app/features/auth/presentation/auth_state.dart';

class AppDrawer extends ConsumerStatefulWidget {
  const AppDrawer({super.key});

  @override
  ConsumerState<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends ConsumerState<AppDrawer>
    with SingleTickerProviderStateMixin {
  static const Color maroon = Color(0xFF600000);
  static const Color beige = AppTheme.luxuryBeige;

  late AnimationController _controller;
  late Animation<double> _avatarScale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _avatarScale = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final bool isGuest = authState is! AuthSuccess;
    final user = !isGuest ? authState.user : null;

    return Drawer(
      backgroundColor: beige,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [maroon, Color(0xFF7A0A0A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(35),
                bottomRight: Radius.circular(35),
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  ScaleTransition(
                    scale: _avatarScale,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.white,
                        backgroundImage: (!isGuest &&
                                user?.imageUrl != null &&
                                user!.imageUrl!.isNotEmpty)
                            ? NetworkImage(user.imageUrl!)
                            : null,
                        child: (isGuest ||
                                user?.imageUrl == null ||
                                user!.imageUrl!.isEmpty)
                            ? const Icon(
                                Icons.person,
                                color: maroon,
                                size: 42,
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    !isGuest
                        ? (user!.name ??
                            user.brandName ??
                            AppStrings.defaultUserName.tr)
                        : AppStrings.welcomeToApp.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    !isGuest
                        ? (user!.phoneNumber ?? "")
                        : AppStrings.loginForFullExperience.tr,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 2),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                if (!isGuest) ...[
                  _item(
                    icon: Icons.person_outline,
                    title: AppStrings.editProfile.tr,
                    color: maroon,
                    onTap: () {
                      context.pop();
                      context.push('/customer/profile');
                    },
                  ),
                  _line(),
                  _item(
                    icon: Icons.calendar_month,
                    title: AppStrings.myBookings.tr,
                    color: _blend(maroon),
                    onTap: () {
                      context.pop();
                      context.push('/customer/bookings');
                    },
                  ),
                  _item(
                    icon: Icons.favorite_border,
                    title: AppStrings.myFavorites.tr,
                    color: Colors.redAccent,
                    onTap: () {
                      context.pop();
                      context.push('/customer/favorites');
                    },
                  ),
                  _line(),
                ],

                if (!isGuest &&
                    (user!.role == 'provider' || user.role == 'admin')) ...[
                  _item(
                    icon: Icons.dashboard,
                    title: AppStrings.dashboard.tr,
                    color: Colors.orange,
                    onTap: () {
                      context.pop();
                      context.push('/provider/dashboard');
                    },
                  ),
                  _item(
                    icon: Icons.calendar_today,
                    title: AppStrings.manageBookings.tr,
                    color: _blend(maroon),
                    onTap: () {
                      context.pop();
                      context.push('/provider/bookings');
                    },
                  ),
                  _item(
                    icon: Icons.category,
                    title: AppStrings.myServices.tr,
                    color: Colors.indigo,
                    onTap: () {
                      context.pop();
                      context.push('/provider/my-services');
                    },
                  ),
                  _line(),
                ],

                _item(
                  icon: Icons.settings,
                  title: AppStrings.settings.tr,
                  color: Colors.grey,
                  onTap: () {
                    context.pop();
                    context.push('/customer/settings');
                  },
                ),
                _item(
                  icon: Icons.info_outline,
                  title: AppStrings.whatIsMabrouk.tr,
                  color: _blend(maroon),
                  onTap: () {
                    context.pop();
                    context.push('/customer/about');
                  },
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(
              left: 12,
              right: 12,
              bottom: 11,
            ),
            child: Divider(
              thickness: 0.6,
              color: maroon.withOpacity(0.25),
            ),
          ),

          Container(
            padding: const EdgeInsets.only(
              left: 12,
              right: 12,
              top: 0,
              bottom: 36,
            ),
            child: _item(
              icon: isGuest ? Icons.login : Icons.logout,
              title: isGuest
                  ? AppStrings.loginOrRegister.tr
                  : AppStrings.logout.tr,
              color: maroon,
              isFooter: true,
              onTap: () async {
  context.pop();

  if (isGuest) {
    context.go('/login');
  } else {
    await ref.read(authStateProvider.notifier).logout();

    if (mounted) {
      context.go('/login');
    }
  }
},
            ),
          ),
        ],
      ),
    );
  }

  Widget _line() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Divider(
        thickness: 0.6,
        color: maroon.withOpacity(0.25),
        indent: 12,
        endIndent: 12,
      ),
    );
  }

  Color _blend(Color base) {
    return Color.lerp(base, beige, 0.2)!;
  }

  Widget _item({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    bool isFooter = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: isFooter ? 16 : 15,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: onTap,
      ),
    );
  }
}