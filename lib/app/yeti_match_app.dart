import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_config.dart';
import '../models/manifest.dart';
import '../models/quiz.dart';
import '../screens/category_detail_screen.dart';
import '../screens/error_screen.dart';
import '../screens/home_screen.dart';
import '../screens/loading_screen.dart';
import '../screens/paywall_screen.dart';
import '../screens/quiz_screen.dart';
import '../screens/result_screen.dart';
import '../screens/sign_in_screen.dart';
import '../screens/sign_up_screen.dart';
import '../screens/welcome_screen.dart';
import '../services/auth_service_interface.dart';
import '../services/firestore_service_interface.dart';
import '../services/prefs_service.dart';
import '../services/quiz_api.dart';
import '../services/quiz_service.dart';
import '../services/subscription_service.dart';
import '../state/quiz_state.dart';
import '../theme/app_theme.dart';

const _freeQuizLimit = 4;

enum _AppScreen {
  home,
  categoryDetail,
  loadingQuiz,
  signIn,
  signUp,
  paywall,
  welcome,
  quiz,
  result,
}

class YetiMatchApp extends StatefulWidget {
  const YetiMatchApp({
    super.key,
    required this.prefs,
    required this.auth,
    required this.firestore,
  });

  final PrefsService prefs;
  final IAuthService auth;
  final IFirestoreService firestore;

  @override
  State<YetiMatchApp> createState() => _YetiMatchAppState();
}

class _YetiMatchAppState extends State<YetiMatchApp> {
  final QuizService _quizService = QuizService();
  final QuizApi _quizApi = QuizApi();
  final QuizState _quizState = QuizState();

  _AppScreen _screen = _AppScreen.home;
  String? _categoryId;
  String? _pendingQuizId;
  QuizManifest? _manifest;
  String? _loadError;
  bool _isLoadingManifest = true;
  bool _isLoadingQuiz = false;
  String _searchQuery = '';
  String? _signedInEmail;
  bool _hasUnlimited = false;
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.prefs.getThemeMode();
    _signedInEmail = widget.auth.currentUserEmail;
    _loadManifest();
    _refreshSubscription();
    if (widget.auth.currentUserId != null) {
      SubscriptionService.loginUser(widget.auth.currentUserId!);
    }
  }

  Future<void> _loadManifest() async {
    setState(() {
      _isLoadingManifest = true;
      _loadError = null;
    });
    try {
      final manifestJson =
          await rootBundle.loadString('assets/manifest.json');
      var manifest = _quizService.loadManifestFromJson(manifestJson);
      if (AppConfig.apiKey.isNotEmpty) {
        try {
          final apiQuizzes = await _quizApi.listQuizzes();
          if (apiQuizzes.isNotEmpty) {
            manifest = QuizManifest(
              categories: manifest.categories,
              quizzes: apiQuizzes
                  .map((q) => QuizMeta(
                        id: q.id,
                        title: q.title,
                        description: q.description,
                        categoryId: q.categoryId.isEmpty
                            ? _quizApi.getCategoryForQuiz(q.id)
                            : q.categoryId,
                        resourcePath: '',
                      ))
                  .toList(),
            );
          }
        } catch (_) {
          // Offline, timeout, or API error: keep bundled manifest.
        }
      }
      if (!mounted) return;
      setState(() {
        _manifest = manifest;
        _isLoadingManifest = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString();
        _isLoadingManifest = false;
      });
    }
  }

  Future<void> _refreshSubscription() async {
    final has = await SubscriptionService.hasUnlimitedAccess();
    if (!mounted) return;
    setState(() => _hasUnlimited = has);
  }

  Future<void> _loadQuizById(String quizId) async {
    setState(() => _isLoadingQuiz = true);
    try {
      Quiz? quiz;
      if (AppConfig.apiKey.isNotEmpty) {
        quiz = await _quizApi.getQuiz(quizId);
      }
      if (quiz == null && _manifest != null) {
        final qList =
            _manifest!.quizzes.where((q) => q.id == quizId).toList();
        final meta = qList.isEmpty ? null : qList.first;
        if (meta != null && meta.resourcePath.isNotEmpty) {
          final path = meta.resourcePath.startsWith('assets/')
              ? meta.resourcePath
              : 'assets/${meta.resourcePath}';
          final json = await rootBundle.loadString(path);
          quiz = _quizService.loadQuizFromJson(json);
        }
      }
      if (!mounted) return;
      if (quiz != null) {
        _quizState.startQuiz(quiz);
        setState(() {
          _isLoadingQuiz = false;
          _screen = _AppScreen.welcome;
        });
      } else {
        setState(() {
          _isLoadingQuiz = false;
          _loadError = 'Quiz not found';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingQuiz = false;
        _loadError = e.toString();
      });
    }
  }

  void _onQuizTap(QuizMeta meta) {
    if (_hasUnlimited) {
      _pendingQuizId = meta.id;
      _screen = _AppScreen.loadingQuiz;
      _loadQuizById(meta.id);
      return;
    }
    final count = widget.prefs.getQuizzesTakenCount();
    final signedIn = widget.auth.currentUserEmail != null;
    if (count >= _freeQuizLimit && !signedIn) {
      _pendingQuizId = meta.id;
      setState(() => _screen = _AppScreen.signIn);
      return;
    }
    if (count >= _freeQuizLimit && !_hasUnlimited) {
      _pendingQuizId = meta.id;
      setState(() => _screen = _AppScreen.paywall);
      return;
    }
    _pendingQuizId = meta.id;
    _screen = _AppScreen.loadingQuiz;
    _loadQuizById(meta.id);
  }

  Future<void> _onSignInSuccess() async {
    await widget.firestore.ensureUserOnSignIn();
    final uid = widget.auth.currentUserId;
    if (uid != null) await SubscriptionService.loginUser(uid);
    setState(() => _signedInEmail = widget.auth.currentUserEmail);
    await _refreshSubscription();
    if (_pendingQuizId != null) {
      if (_hasUnlimited) {
        _loadQuizById(_pendingQuizId!);
        setState(() => _screen = _AppScreen.loadingQuiz);
      } else {
        setState(() => _screen = _AppScreen.paywall);
      }
    } else {
      setState(() => _screen = _AppScreen.home);
    }
  }

  Future<void> _onSignUpSuccess() async {
    await _onSignInSuccess();
  }

  void _onPaywallDismiss() {
    setState(() {
      _screen = _AppScreen.home;
      _pendingQuizId = null;
    });
  }

  Future<void> _onPaywallPurchaseCompleted() async {
    await _refreshSubscription();
    if (_pendingQuizId != null && _hasUnlimited) {
      _loadQuizById(_pendingQuizId!);
      setState(() => _screen = _AppScreen.loadingQuiz);
    } else {
      setState(() {
        _screen = _AppScreen.home;
        _pendingQuizId = null;
      });
    }
  }

  Future<void> _onPaywallRestoreCompleted() async {
    await _refreshSubscription();
    if (_pendingQuizId != null && _hasUnlimited) {
      _loadQuizById(_pendingQuizId!);
      setState(() => _screen = _AppScreen.loadingQuiz);
    } else {
      setState(() {
        _screen = _AppScreen.home;
        _pendingQuizId = null;
      });
    }
  }

  void _onQuizComplete() {
    widget.prefs.setQuizzesTakenCount(
        widget.prefs.getQuizzesTakenCount() + 1);
    final uid = widget.auth.currentUserId;
    final quiz = _quizState.currentQuiz;
    final result = _quizState.result;
    if (uid != null && quiz != null && result != null) {
      widget.firestore.ensureUserOnSignIn();
      widget.firestore.saveQuizResult(quiz.id, quiz.title, result);
    }
    setState(() => _screen = _AppScreen.result);
  }

  bool get _showBack =>
      _screen == _AppScreen.categoryDetail ||
      _screen == _AppScreen.signIn ||
      _screen == _AppScreen.signUp ||
      _screen == _AppScreen.paywall;

  String get _appBarTitle {
    switch (_screen) {
      case _AppScreen.categoryDetail:
        final list = _manifest?.categories
                .where((c) => c.id == _categoryId)
                .toList();
        final name = (list != null && list.isNotEmpty)
            ? list.first.name
            : 'Category';
        return name;
      case _AppScreen.signIn:
        return 'Sign in';
      case _AppScreen.signUp:
        return 'Sign up';
      case _AppScreen.paywall:
        return 'Upgrade';
      default:
        return 'YetiMatch';
    }
  }

  bool _isDark() {
    switch (_themeMode) {
      case ThemeMode.light:
        return false;
      case ThemeMode.dark:
        return true;
      case ThemeMode.system:
        return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_screen == _AppScreen.loadingQuiz && !_isLoadingQuiz) {
      if (_quizState.currentQuiz != null) {
        _screen = _AppScreen.welcome;
      } else {
        _screen = _AppScreen.home;
      }
    }

    return MaterialApp(
      title: 'YetiMatch',
      theme: yetiMatchTheme(dark: false),
      darkTheme: yetiMatchTheme(dark: true),
      themeMode: _themeMode,
      home: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Image.asset(
                  Theme.of(context).brightness == Brightness.dark
                      ? 'assets/images/yetimatch_dark_bg.png'
                      : 'assets/images/yetimatch.png',
                  height: 32,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 8),
                Text(_appBarTitle),
              ],
            ),
            leading: _showBack
                ? IconButton(
                    icon: const Text('<'),
                    onPressed: () =>
                        setState(() => _screen = _AppScreen.home),
                  )
                : null,
            actions: [
              Switch(
                value: _isDark(),
                onChanged: (v) {
                  final next = v ? ThemeMode.dark : ThemeMode.light;
                  widget.prefs.setThemeMode(next);
                  setState(() => _themeMode = next);
                },
              ),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'account' || value == 'email') return;
                  switch (value) {
                    case 'sign_in':
                      _pendingQuizId = null;
                      setState(() => _screen = _AppScreen.signIn);
                      break;
                    case 'sign_out':
                      await widget.auth.signOut();
                      await SubscriptionService.logout();
                      setState(() {
                        _signedInEmail = null;
                        _screen = _AppScreen.home;
                      });
                      break;
                    case 'delete':
                      _showDeleteAccountDialog();
                      break;
                    case 'privacy':
                      _openUrl(AppConfig.privacyPolicyUrl);
                      break;
                    case 'support':
                      _openUrl(AppConfig.supportUrl);
                      break;
                    case 'upgrade':
                      _pendingQuizId = null;
                      setState(() => _screen = _AppScreen.paywall);
                      break;
                  }
                },
                itemBuilder: (ctx) => [
                  if (_signedInEmail != null) ...[
                    const PopupMenuItem(
                        value: 'account', child: Text('Account')),
                    PopupMenuItem(
                        value: 'email', child: Text(_signedInEmail!)),
                    const PopupMenuItem(
                        value: 'sign_out', child: Text('Sign out')),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete account',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ] else
                    const PopupMenuItem(
                        value: 'sign_in', child: Text('Sign in')),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                      value: 'privacy', child: Text('Privacy policy')),
                  const PopupMenuItem(value: 'support', child: Text('Support')),
                  if (!_hasUnlimited)
                    const PopupMenuItem(
                      value: 'upgrade',
                      child: Text('Upgrade to Premium'),
                    ),
                ],
              ),
            ],
          ),
          body: _buildBody(),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
          'Your account and all associated data will be permanently deleted. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final r = await widget.auth.deleteAccount();
              if (!mounted) return;
              if (r.error != null) {
                showDialog<void>(
                  context: context,
                  builder: (c) => AlertDialog(
                    title: const Text('Error'),
                    content: Text(r.error!),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(c).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
                return;
              }
              await widget.auth.signOut();
              await SubscriptionService.logout();
              widget.prefs.setQuizzesTakenCount(0);
              if (!mounted) return;
              setState(() {
                _signedInEmail = null;
                _screen = _AppScreen.home;
              });
            },
            child: Text('Delete',
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoadingManifest && _manifest == null) {
      return const LoadingScreen(message: 'Loading...');
    }
    if (_loadError != null && _manifest == null) {
      return ErrorScreen(
        message: _loadError!,
        onRetry: _loadManifest,
      );
    }

    switch (_screen) {
      case _AppScreen.signIn:
        return SignInScreen(
          message: _pendingQuizId != null
              ? "You've completed $_freeQuizLimit free quizzes. Sign in to continue."
              : 'Sign in to sync your progress and unlock features.',
          onSuccess: _onSignInSuccess,
          onGoToSignUp: () =>
              setState(() => _screen = _AppScreen.signUp),
          onCancel: () => setState(() {
                _screen = _AppScreen.home;
                _pendingQuizId = null;
              }),
          onSignIn: (e, p) async {
            final r = await widget.auth.signInWithEmail(e, p);
            return r.error;
          },
          onSendPasswordReset: (e) async {
            final r = await widget.auth.sendPasswordResetEmail(e);
            return r.error;
          },
        );
      case _AppScreen.signUp:
        return SignUpScreen(
          message: _pendingQuizId != null
              ? "You've completed $_freeQuizLimit free quizzes. Create an account to continue."
              : 'Create an account to sync your progress and unlock features.',
          onSuccess: _onSignUpSuccess,
          onGoToSignIn: () =>
              setState(() => _screen = _AppScreen.signIn),
          onCancel: () => setState(() {
                _screen = _AppScreen.home;
                _pendingQuizId = null;
              }),
          onSignUp: (e, p) async {
            final r = await widget.auth.signUpWithEmail(e, p);
            return r.error;
          },
        );
      case _AppScreen.paywall:
        return PaywallScreen(
          onDismiss: _onPaywallDismiss,
          onPurchaseCompleted: _onPaywallPurchaseCompleted,
          onRestoreCompleted: _onPaywallRestoreCompleted,
        );
      case _AppScreen.loadingQuiz:
        return const LoadingScreen(message: 'Loading quiz...');
      case _AppScreen.home:
        return HomeScreen(
          manifest: _manifest,
          searchQuery: _searchQuery,
          onSearchQueryChange: (q) => setState(() => _searchQuery = q),
          onCategoryClick: (id) => setState(() {
                _categoryId = id;
                _screen = _AppScreen.categoryDetail;
              }),
          onQuizClick: _onQuizTap,
        );
      case _AppScreen.categoryDetail:
        final quizzes = _manifest?.quizzes
                .where((q) => q.categoryId == _categoryId)
                .toList() ??
            [];
        return CategoryDetailScreen(
          categoryName: _appBarTitle,
          quizzes: quizzes,
          onQuizClick: _onQuizTap,
        );
      case _AppScreen.welcome:
        return WelcomeScreen(
          quizTitle: _quizState.currentQuiz?.title ?? 'YetiMatch',
          quizDescription:
              _quizState.currentQuiz?.description ?? '',
          onStartQuiz: () =>
              setState(() => _screen = _AppScreen.quiz),
        );
      case _AppScreen.quiz:
        return QuizScreen(
          quizState: _quizState,
          onQuizComplete: _onQuizComplete,
        );
      case _AppScreen.result:
        return ResultScreen(
          quizState: _quizState,
          onRetakeQuiz: () =>
              setState(() => _screen = _AppScreen.quiz),
          onBackToHome: () => setState(() => _screen = _AppScreen.home),
        );
    }
  }
}
