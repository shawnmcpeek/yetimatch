import 'dart:async' show TimeoutException, unawaited;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_config.dart';
import '../models/manifest.dart';
import '../models/quiz.dart';
import '../models/saved_quiz_result.dart';
import '../screens/category_detail_screen.dart';
import '../screens/error_screen.dart';
import '../screens/history_screen.dart';
import '../screens/home_screen.dart';
import '../screens/loading_screen.dart';
import '../screens/paywall_screen.dart';
import '../screens/quiz_screen.dart';
import '../screens/result_screen.dart';
import '../screens/sign_in_screen.dart';
import '../screens/sign_up_screen.dart';
import '../screens/welcome_screen.dart';
import '../services/auth_service_interface.dart';
import '../services/error_reporting.dart';
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
  history,
  historyDetail,
  welcome,
  quiz,
  result,
}

class YetiMatchApp extends StatefulWidget {
  YetiMatchApp({
    super.key,
    required this.prefs,
    required this.auth,
    required this.firestore,
    ErrorReporting? errorReporting,
    QuizApi? quizApi,
  })  : errorReporting = errorReporting ?? NoOpErrorReporting(),
        quizApi = quizApi ?? QuizApi();

  final PrefsService prefs;
  final IAuthService auth;
  final IFirestoreService firestore;
  final ErrorReporting errorReporting;
  final QuizApi quizApi;

  @override
  State<YetiMatchApp> createState() => _YetiMatchAppState();
}

class _YetiMatchAppState extends State<YetiMatchApp> {
  final QuizService _quizService = QuizService();
  late final QuizApi _quizApi = widget.quizApi;
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
  bool _isAnonymous = false;
  bool _hasUnlimited = false;
  ThemeMode _themeMode = ThemeMode.system;

  List<SavedQuizResult> _historyResults = [];
  bool _historyLoading = false;
  String? _historyError;
  SavedQuizResult? _selectedHistoryResult;
  bool _handlingQuizComplete = false;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  BuildContext? get _dialogContext =>
      _navigatorKey.currentContext ?? _scaffoldMessengerKey.currentContext;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.prefs.getThemeMode();
    _syncAuthUiState();
    unawaited(widget.errorReporting.setUserId(widget.auth.currentUserId));
    _loadManifest();
    unawaited(_bootstrapSubscriptionsAfterFirstFrame());
  }

  void _syncAuthUiState() {
    _signedInEmail = widget.auth.currentUserEmail;
    _isAnonymous = widget.auth.isAnonymous;
    unawaited(widget.errorReporting.setUserId(widget.auth.currentUserId));
  }

  /// Runs after [runApp] so the UI is not blocked by RevenueCat (see [main]).
  Future<void> _bootstrapSubscriptionsAfterFirstFrame() async {
    if (!AppConfig.subscriptionsEnabled) {
      if (mounted) setState(() => _hasUnlimited = true);
      return;
    }
    try {
      await SubscriptionService.configure()
          .timeout(const Duration(seconds: 20));
    } on TimeoutException {
      debugPrint(
        'YetiMatch: RevenueCat.configure timed out; continuing without entitlement.',
      );
    } catch (_) {
      // configure() already logs; continue without subscriptions.
    }
    if (!mounted) return;
    final uid = widget.auth.currentUserId;
    if (uid != null) {
      await SubscriptionService.loginUser(uid);
    }
    await _refreshSubscription();
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
            final bundledById = {
              for (final q in manifest.quizzes) q.id: q,
            };
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
                        // Keep bundled asset paths so offline load can fall back.
                        resourcePath: bundledById[q.id]?.resourcePath ?? '',
                      ))
                  .toList(),
            );
          }
        } catch (e, st) {
          // Offline, timeout, or API error: keep bundled manifest.
          unawaited(widget.errorReporting
              .recordError(e, st, reason: 'listQuizzes'));
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
    if (count >= _freeQuizLimit) {
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
    setState(_syncAuthUiState);
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

  Future<void> _afterUnlock() async {
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
    if (_hasUnlimited && widget.auth.isAnonymous) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showCreateAccountForSyncPrompt();
      });
    }
  }

  Future<void> _onPaywallPurchaseCompleted() async {
    await _afterUnlock();
  }

  Future<void> _onPaywallRestoreCompleted() async {
    await _afterUnlock();
  }

  void _showCreateAccountForSyncPrompt() {
    final dialogContext = _dialogContext;
    if (dialogContext == null) return;
    showDialog<void>(
      context: dialogContext,
      builder: (ctx) => AlertDialog(
        title: const Text('Save your results?'),
        content: const Text(
          'Create an account to keep your quiz history and unlock it on other devices.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _pendingQuizId = null;
              setState(() => _screen = _AppScreen.signUp);
            },
            child: const Text('Create account'),
          ),
        ],
      ),
    );
  }

  Future<void> _onQuizComplete() async {
    if (_handlingQuizComplete) return;
    _handlingQuizComplete = true;

    String? saveError;
    try {
      final quiz = _quizState.currentQuiz;
      final result = _quizState.result;
      if (quiz != null && result != null) {
        if (widget.auth.currentUserId == null) {
          final anon = await widget.auth.ensureAnonymousUser();
          if (anon.error != null) {
            saveError = anon.error;
            await widget.errorReporting
                .log('Anonymous auth failed: ${anon.error}');
          }
        }
        final uid = widget.auth.currentUserId;
        if (uid != null) {
          try {
            await SubscriptionService.loginUser(uid);
            await widget.firestore.ensureUserOnSignIn();
            await widget.firestore
                .saveQuizResult(quiz.id, quiz.title, result);
          } catch (e, st) {
            saveError = e.toString();
            await widget.errorReporting
                .recordError(e, st, reason: 'saveQuizResult');
          }
        }
      }

      await widget.prefs.setQuizzesTakenCount(
          widget.prefs.getQuizzesTakenCount() + 1);

      if (!mounted) return;
      setState(() {
        _syncAuthUiState();
        _screen = _AppScreen.result;
      });
      if (saveError != null) {
        _scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text(
              'Result shown, but saving to your account failed. Check your connection.',
            ),
          ),
        );
      }
    } catch (e, st) {
      await widget.errorReporting
          .recordError(e, st, reason: 'onQuizComplete');
      if (mounted) {
        setState(() => _screen = _AppScreen.result);
      }
    }
  }

  void _resetQuizCompletionGuard() {
    _handlingQuizComplete = false;
  }

  Future<void> _goToSignIn() async {
    _pendingQuizId = null;
    if (widget.auth.isAnonymous) {
      final dialogContext = _dialogContext;
      if (dialogContext == null) return;
      final proceed = await showDialog<bool>(
        context: dialogContext,
        builder: (ctx) => AlertDialog(
          title: const Text('Sign in to another account?'),
          content: const Text(
            'Signing in to an existing account leaves this device’s guest '
            'results behind. Create an account instead to keep them.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(false);
                setState(() => _screen = _AppScreen.signUp);
              },
              child: const Text('Create account'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Sign in anyway'),
            ),
          ],
        ),
      );
      if (proceed != true || !mounted) return;
    }
    setState(() => _screen = _AppScreen.signIn);
  }

  Future<void> _openHistory() async {
    setState(() {
      _screen = _AppScreen.history;
      _historyLoading = true;
      _historyError = null;
      _selectedHistoryResult = null;
    });
    try {
      final results = await widget.firestore.listQuizResults();
      if (!mounted) return;
      setState(() {
        _historyResults = results;
        _historyLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _historyError = e.toString();
        _historyLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    await widget.auth.signOut();
    await SubscriptionService.logout();
    await _refreshSubscription();
    if (!mounted) return;
    setState(() {
      _syncAuthUiState();
      _screen = _AppScreen.home;
      _historyResults = [];
      _selectedHistoryResult = null;
    });
  }

  bool get _showBack =>
      _screen == _AppScreen.categoryDetail ||
      _screen == _AppScreen.signIn ||
      _screen == _AppScreen.signUp ||
      _screen == _AppScreen.paywall ||
      _screen == _AppScreen.history ||
      _screen == _AppScreen.historyDetail;

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
        return 'Create account';
      case _AppScreen.paywall:
        return 'Upgrade';
      case _AppScreen.history:
        return 'My results';
      case _AppScreen.historyDetail:
        return _selectedHistoryResult?.quizTitle.isNotEmpty == true
            ? _selectedHistoryResult!.quizTitle
            : 'Result';
      default:
        return 'YetiMatch';
    }
  }

  void _onBack() {
    setState(() {
      if (_screen == _AppScreen.historyDetail) {
        _screen = _AppScreen.history;
        _selectedHistoryResult = null;
      } else {
        _screen = _AppScreen.home;
        _pendingQuizId = null;
      }
    });
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
      navigatorKey: _navigatorKey,
      scaffoldMessengerKey: _scaffoldMessengerKey,
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
                    icon: const Icon(Icons.arrow_back),
                    tooltip: 'Back',
                    onPressed: _onBack,
                  )
                : null,
            actions: [
              Semantics(
                label: 'Toggle dark mode',
                child: Switch(
                  value: _isDark(),
                  onChanged: (v) {
                    final next = v ? ThemeMode.dark : ThemeMode.light;
                    widget.prefs.setThemeMode(next);
                    setState(() => _themeMode = next);
                  },
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Menu',
                onSelected: (value) async {
                  if (value == 'account' || value == 'email') return;
                  switch (value) {
                    case 'sign_in':
                      await _goToSignIn();
                      break;
                    case 'sign_up':
                      _pendingQuizId = null;
                      setState(() => _screen = _AppScreen.signUp);
                      break;
                    case 'sign_out':
                      await _signOut();
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
                    case 'history':
                      await _openHistory();
                      break;
                  }
                },
                itemBuilder: (ctx) {
                  final items = <PopupMenuEntry<String>>[];
                  if (widget.auth.hasEmailAccount) {
                    items.addAll([
                      const PopupMenuItem(
                          value: 'account', child: Text('Account')),
                      PopupMenuItem(
                          value: 'email',
                          child: Text(_signedInEmail ?? '')),
                      const PopupMenuItem(
                          value: 'sign_out', child: Text('Sign out')),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete account',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ]);
                  } else if (_isAnonymous) {
                    items.addAll([
                      const PopupMenuItem(
                          value: 'sign_up',
                          child: Text('Create account')),
                      const PopupMenuItem(
                          value: 'sign_in', child: Text('Sign in')),
                    ]);
                  } else {
                    items.add(const PopupMenuItem(
                        value: 'sign_in', child: Text('Sign in')));
                  }
                  if (_hasUnlimited && widget.auth.currentUserId != null) {
                    items.add(const PopupMenuItem(
                        value: 'history', child: Text('My results')));
                  }
                  items.addAll([
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                        value: 'privacy', child: Text('Privacy policy')),
                    const PopupMenuItem(
                        value: 'support', child: Text('Support')),
                  ]);
                  if (AppConfig.subscriptionsEnabled && !_hasUnlimited) {
                    items.add(const PopupMenuItem(
                      value: 'upgrade',
                      child: Text('Upgrade to Premium'),
                    ));
                  }
                  return items;
                },
              ),
            ],
          ),
          body: _buildBody(),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    final dialogContext = _dialogContext;
    if (dialogContext == null) return;
    showDialog<void>(
      context: dialogContext,
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
              try {
                await widget.firestore.deleteUserData();
              } catch (e, st) {
                await widget.errorReporting
                    .recordError(e, st, reason: 'deleteUserData');
              }
              final r = await widget.auth.deleteAccount();
              if (!mounted) return;
              if (r.error != null) {
                final errContext = _dialogContext;
                if (errContext != null && errContext.mounted) {
                  showDialog<void>(
                    context: errContext,
                    builder: (c) => AlertDialog(
                      title: const Text('Error'),
                      content: Text(
                        '${r.error!}\n\nIf you signed in a while ago, sign out, '
                        'sign back in, then try deleting again.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(c).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
                return;
              }
              await SubscriptionService.logout();
              await widget.prefs.setQuizzesTakenCount(0);
              await _refreshSubscription();
              if (!mounted) return;
              setState(() {
                _syncAuthUiState();
                _screen = _AppScreen.home;
              });
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(ctx).colorScheme.error),
            ),
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
          message: 'Sign in to restore your results on this device.',
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
          message: _isAnonymous
              ? 'Create an account to keep your quiz history and use it on other devices.'
              : 'Create an account to sync your quiz history across devices.',
          onSuccess: _onSignUpSuccess,
          onGoToSignIn: () => unawaited(_goToSignIn()),
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
      case _AppScreen.history:
        return HistoryScreen(
          results: _historyResults,
          loading: _historyLoading,
          error: _historyError,
          onRetry: _openHistory,
          onOpenResult: (r) => setState(() {
                _selectedHistoryResult = r;
                _screen = _AppScreen.historyDetail;
              }),
        );
      case _AppScreen.historyDetail:
        final selected = _selectedHistoryResult;
        if (selected == null) {
          return HistoryScreen(
            results: _historyResults,
            loading: false,
            error: null,
            onRetry: _openHistory,
            onOpenResult: (r) => setState(() {
                  _selectedHistoryResult = r;
                  _screen = _AppScreen.historyDetail;
                }),
          );
        }
        return HistoryDetailScreen(result: selected);
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
          onQuizComplete: () => unawaited(_onQuizComplete()),
          onLeaveQuiz: () {
            _resetQuizCompletionGuard();
            setState(() => _screen = _AppScreen.home);
          },
        );
      case _AppScreen.result:
        return ResultScreen(
          quizState: _quizState,
          onRetakeQuiz: () {
            _resetQuizCompletionGuard();
            setState(() => _screen = _AppScreen.quiz);
          },
          onBackToHome: () {
            _resetQuizCompletionGuard();
            setState(() => _screen = _AppScreen.home);
          },
        );
    }
  }
}
