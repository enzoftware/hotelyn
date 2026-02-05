# Building Effective Heatmaps in Flutter with Microsoft Clarity

<!-- Learn how to implement Microsoft Clarity in your Flutter application to capture production-quality heatmaps and session recordings for data-driven UX optimization. -->

Understanding where users tap, scroll, and interact within your mobile app is critical for UX optimization. Heatmaps aggregate thousands of user interactions into visual patterns that reveal usability issues no amount of manual testing can uncover.

Microsoft Clarity stands alone as the **only completely free heatmap SDK for Flutter apps with unlimited sessions**. No usage caps, no credit card required, no premium tier restrictions. This makes it the go-to choice for teams who need production-grade analytics without budget constraints.

In this tutorial, you'll learn how to:

- Configure Clarity to generate actionable heatmaps from real user sessions
- Implement strategic privacy masking to protect sensitive data while preserving heatmap accuracy
- Use the mask/unmask widget hierarchy to control exactly what appears in recordings
- Track authenticated users across sessions for cohort analysis
- Interpret heatmap data to identify UX friction points

You'll work through these concepts by integrating Clarity into Hotelyn, a hotel booking application. By the end of this tutorial, you'll have a production-ready heatmap implementation that balances user privacy with analytical depth.

*Note:* This tutorial assumes familiarity with Flutter state management patterns (BLoC) and dependency injection. The implementation follows clean architecture principles with repository-based data access.

## Why Clarity for Flutter Heatmaps

Before diving into implementation, it's worth understanding what sets Clarity apart for mobile heatmap generation.

### The Free Tier Reality

Most analytics SDKs impose session limits, feature gates, or require paid plans for heatmap access. Clarity's offering is genuinely different:

- **100% free forever** with no session caps
- Full heatmap generation across all screens
- Complete session replay functionality
- Rage tap and dead tap detection
- No credit card or enterprise contract required

For teams shipping Flutter apps to production, this eliminates the common trade-off between analytics depth and budget constraints.

### Heatmap-Specific Capabilities

Clarity generates three types of heatmaps from captured sessions:

**Tap Heatmaps**: Aggregate tap locations across all sessions, revealing which UI elements receive the most interaction. Hot zones (red) indicate high-frequency taps; cold zones (blue) show ignored areas.

**Scroll Heatmaps**: Visualize how far users scroll on each screen. The gradient shows attention drop-off, helping you identify content that users never reach.

**Attention Heatmaps**: Combine tap and scroll data to show where users spend the most time. Useful for validating that key CTAs receive appropriate attention.

## Setting Up Clarity

### Creating a Clarity Project

Visit [clarity.microsoft.com](https://clarity.microsoft.com) and sign in with your Microsoft account. Create a new project and select **Mobile App** as the platform. The dashboard will display your **Project ID**—a string like `vaoffuzfn7` that uniquely identifies your app.

### Installing the SDK

Add the Clarity Flutter SDK to your `pubspec.yaml`:

```yaml
dependencies:
  clarity_flutter: ^1.7.1
```

Run `flutter pub get` to fetch the package.

### Initialization with ClarityWidget

The recommended initialization approach wraps your entire app with `ClarityWidget`. This ensures Clarity captures all screen transitions and interactions from the first frame.

Here's the bootstrap configuration from the Hotelyn app:

```dart
// lib/bootstrap.dart
import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    log('onChange(${bloc.runtimeType}, $change)');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }
}

Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  Bloc.observer = const AppBlocObserver();

  final config = ClarityConfig(
    projectId: 'vaoffuzfn7',
    logLevel: kReleaseMode ? LogLevel.None : LogLevel.Verbose,
  );

  runApp(
    ClarityWidget(
      app: await builder(),
      clarityConfig: config,
    ),
  );
}
```

The `ClarityConfig` accepts two parameters:

- **projectId**: Your Clarity project identifier from the dashboard
- **logLevel**: Controls SDK debug output. Use `LogLevel.Verbose` during development to verify integration, then `LogLevel.None` in production to eliminate overhead

The conditional `kReleaseMode` check automatically switches log levels based on build type.

## Privacy Masking Architecture

Heatmap accuracy depends on capturing real user interactions. However, screens containing sensitive data—login forms, payment details, personal information—must be masked to protect user privacy. The challenge is masking the right content without losing valuable interaction data.

### Understanding the Masking Hierarchy

Clarity provides two widgets that work together hierarchically:

- **`ClarityMask`**: Hides all descendant widgets from session recordings. Masked areas appear as solid blocks in replays and contribute no visual data to recordings, but tap locations are still registered for heatmaps.

- **`ClarityUnmask`**: Selectively reveals widgets within a masked parent. This creates a "window" of visibility inside a masked container, allowing you to show non-sensitive content while keeping surrounding sensitive data hidden.

The key insight is that these widgets compose hierarchically. A `ClarityUnmask` inside a `ClarityMask` creates a visibility exception. This pattern enables fine-grained control over what appears in recordings without restructuring your widget tree.

### How Masking Affects Heatmaps

Understanding the technical behavior of masking is critical for accurate heatmap data:

| Aspect | ClarityMask Behavior | ClarityUnmask Behavior |
|--------|---------------------|----------------------|
| Visual in recordings | Solid block overlay | Fully visible |
| Tap coordinates | Still captured | Still captured |
| Text content | Hidden | Visible |
| Heatmap contribution | Tap locations only | Full interaction data |

This means masked areas still contribute to tap heatmaps—you'll see where users tap—but the actual content (text, images) is replaced with a solid mask in session replays. This is the optimal balance for sensitive forms: you get interaction pattern data without exposing user input.

### Masking Login Credentials

Login screens are the canonical masking use case. You want to capture that users interact with the login flow (for conversion analysis) without recording actual credentials.

Here's the implementation from Hotelyn's login page:

```dart
// lib/features/login/view/login_page.dart
class _LoginForm extends StatelessWidget {
  const _LoginForm();

  @override
  Widget build(BuildContext context) {
    return ClarityMask(
      child: Column(
        children: [
          BlocBuilder<LoginCubit, LoginState>(
            buildWhen: (previous, current) => previous.email != current.email,
            builder: (context, state) {
              return HotelynTextInput(
                hintText: 'Email',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) =>
                    context.read<LoginCubit>().emailChanged(value),
                errorText:
                    state.email.displayError != null ? 'Invalid email' : null,
              );
            },
          ),
          const SizedBox(height: 16),
          BlocBuilder<LoginCubit, LoginState>(
            buildWhen: (previous, current) =>
                previous.password != current.password,
            builder: (context, state) {
              return HotelynTextInput(
                hintText: 'Password',
                prefixIcon: Icons.lock_outline,
                obscureText: true,
                onChanged: (value) =>
                    context.read<LoginCubit>().passwordChanged(value),
                errorText: state.password.displayError != null
                    ? 'Password cannot be empty'
                    : null,
              );
            },
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: const Text('Forgot Password?'),
            ),
          ),
          const SizedBox(height: 24),
          BlocBuilder<LoginCubit, LoginState>(
            builder: (context, state) {
              return HotelynButton(
                message: 'Login',
                isLoading: state.status.isInProgress,
                onPressed: () =>
                    context.read<LoginCubit>().logInWithCredentials(),
              );
            },
          ),
        ],
      ),
    );
  }
}
```

The entire form column is wrapped in `ClarityMask`. Session replays will show users tapping in the masked region, but the actual text input is never captured. Heatmaps will still register tap locations, giving you conversion funnel data without exposing credentials.

### Selective Unmasking for Payment Screens

Payment flows require more nuanced masking. You want to hide credit card details while preserving visibility into the booking summary—users should see what they're paying for in replays, and you need heatmap data on how they interact with pricing information.

Here's Hotelyn's payment screen implementation demonstrating the mask/unmask hierarchy:

```dart
// lib/features/payment/view/payment_page.dart
class _PaymentBody extends StatelessWidget {
  const _PaymentBody();

  @override
  Widget build(BuildContext context) {
    return ClarityMask(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // BookingSummaryCard uses ClarityUnmask internally
            const BookingSummaryCard(
              hotelName: 'Grand Plaza Hotel',
              checkIn: 'Dec 15, 2024',
              checkOut: 'Dec 18, 2024',
              totalPrice: r'$690.30',
            ),
            const SizedBox(height: 16),
            // PaymentFormCard remains masked (no ClarityUnmask)
            const PaymentFormCard(),
            const SizedBox(height: 32),
            // CTA button explicitly unmasked for heatmap accuracy
            ClarityUnmask(
              child: HotelynButton(
                message: 'Pay Now',
                onPressed: () {
                  Clarity.setCustomTag(
                    'booking_completed',
                    'hotel_grand_plaza',
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Payment successful!'),
                      backgroundColor: GreenColors.green,
                    ),
                  );
                  Navigator.of(context).pop();
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
```

The outer `ClarityMask` covers the entire scrollable area. Inside, specific widgets break out of masking using `ClarityUnmask`:

```dart
// lib/features/payment/widgets/booking_summary_card.dart
class BookingSummaryCard extends StatelessWidget {
  const BookingSummaryCard({
    required this.hotelName,
    required this.checkIn,
    required this.checkOut,
    required this.totalPrice,
    super.key,
  });

  final String hotelName;
  final String checkIn;
  final String checkOut;
  final String totalPrice;

  @override
  Widget build(BuildContext context) {
    return ClarityUnmask(
      child: Card(
        elevation: 0,
        color: LightGreyColors.lightGrey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Booking Summary', style: HotelynTextStyle.h3),
              const SizedBox(height: 12),
              _SummaryRow(label: 'Hotel', value: hotelName),
              const SizedBox(height: 8),
              _SummaryRow(label: 'Check-in', value: checkIn),
              const SizedBox(height: 8),
              _SummaryRow(label: 'Check-out', value: checkOut),
              const Divider(height: 24),
              _SummaryRow(
                label: 'Total',
                value: totalPrice,
                isBold: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

The `ClarityUnmask` wrapper on `BookingSummaryCard` creates a visibility window within the masked payment body. Session replays show the booking details while payment inputs remain hidden.

Meanwhile, the `PaymentFormCard` contains sensitive payment fields and remains within the masked parent without any `ClarityUnmask`:

```dart
// lib/features/payment/widgets/payment_form_card.dart
class PaymentFormCard extends StatelessWidget {
  const PaymentFormCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: LightGreyColors.lightGrey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Payment Details', style: HotelynTextStyle.h3),
            SizedBox(height: 16),
            HotelynTextInput(
              hintText: 'Card Number',
              prefixIcon: Icons.credit_card,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 12),
            _ExpiryAndCvvRow(),
            SizedBox(height: 12),
            HotelynTextInput(
              hintText: 'Cardholder Name',
              prefixIcon: Icons.person_outline,
            ),
          ],
        ),
      ),
    );
  }
}
```

This pattern—mask the container, unmask safe children—scales to any screen with mixed sensitivity levels.

### Strategic Masking Guidelines

| Scenario | Pattern | Rationale |
|----------|---------|-----------|
| Login/registration forms | `ClarityMask` on entire form | All inputs contain credentials |
| Payment screens | `ClarityMask` container + `ClarityUnmask` on summary/CTAs | Mix of PCI-sensitive and safe content |
| Profile screens | `ClarityMask` on PII fields only | Most content is safe to display |
| Settings screens | No masking typically needed | Configuration data is not sensitive |
| Search/browse screens | No masking needed | Maximize heatmap coverage |
| Medical/health data | `ClarityMask` + consider `Clarity.pause()` | HIPAA compliance may require no capture |

The goal is maximizing heatmap data collection while ensuring no sensitive information appears in recordings.

## Tracking Authenticated Users

Heatmaps become significantly more valuable when you can segment by user cohorts. Clarity supports custom user IDs that persist across sessions, enabling analysis like "how do power users interact differently than new users?"

### Setting Up User Identification

The Hotelyn app implements user persistence through a dedicated `AuthRepository` that coordinates between local storage and Clarity:

```dart
// lib/core/domain/repository/auth_repository.dart
import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:hotelyn/core/data/storage/storage.dart';

class AuthRepository {
  AuthRepository({
    required SharedStorage sharedStorage,
  }) : _sharedStorage = sharedStorage;

  final SharedStorage _sharedStorage;

  bool get isAuthenticated => _sharedStorage.getUserId() != null;

  String? get currentUserId => _sharedStorage.getUserId();

  Future<String> login() async {
    final userId = await _sharedStorage.setUserId();
    Clarity.setCustomUserId(userId);
    Clarity.setCustomTag('login_success', 'credentials');
    return userId;
  }

  Future<void> logout() async {
    await _sharedStorage.clearUserId();
  }

  void initializeClarityUser() {
    final userId = currentUserId;
    if (userId != null) {
      Clarity.setCustomUserId(userId);
    }
  }
}
```

The repository handles three concerns:

1. **Login**: Generates a UUID, persists it locally, and registers it with Clarity via `setCustomUserId()`
2. **App startup**: Checks for existing user ID and re-registers with Clarity for returning users
3. **Logout**: Clears persisted credentials (Clarity sessions continue with anonymous tracking)

The storage layer uses SharedPreferences with UUID generation:

```dart
// lib/core/data/storage/shared_storage.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class SharedStorage {
  SharedStorage({required this.sharedPreferences});

  final SharedPreferences sharedPreferences;

  static const introItemKey = 'intro_passed';
  static const userIdKey = 'user_id';

  Future<bool> isIntroPassed() async {
    return sharedPreferences.getBool(introItemKey) ?? false;
  }

  void setIntroPassed() => sharedPreferences.setBool(introItemKey, true);

  String? getUserId() {
    return sharedPreferences.getString(userIdKey);
  }

  Future<String> setUserId() async {
    final userId = const Uuid().v4();
    await sharedPreferences.setString(userIdKey, userId);
    return userId;
  }

  Future<void> clearUserId() async {
    await sharedPreferences.remove(userIdKey);
  }
}
```

### Initializing on App Startup

For returning users, you must set the Clarity user ID before any sessions are recorded. The Hotelyn splash screen handles this through the `SplashBloc`:

```dart
// lib/features/splash/bloc/splash_bloc.dart
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hotelyn/core/domain/repository/repository.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc({
    required IntroRepository introRepository,
    required AuthRepository authRepository,
  })  : _introRepository = introRepository,
        _authRepository = authRepository,
        super(SplashInitial()) {
    on<SplashStarted>(_onStartSplash);
  }

  final IntroRepository _introRepository;
  final AuthRepository _authRepository;

  FutureOr<void> _onStartSplash(
    SplashStarted event,
    Emitter<SplashState> emit,
  ) async {
    final introPassed = await _introRepository.isIntroPassed();

    if (!introPassed) {
      emit(SplashToIntro());
      return;
    }

    // Check if user is authenticated
    if (_authRepository.isAuthenticated) {
      // Initialize Clarity with the stored user ID for returning users
      _authRepository.initializeClarityUser();
      emit(SplashToHome());
    } else {
      emit(SplashToLogin());
    }
  }
}
```

The key line is `_authRepository.initializeClarityUser()`, which calls `Clarity.setCustomUserId()` before navigating to the home screen. This ensures all subsequent session data is attributed to the correct user.

### Setting User ID on Login

When a new user authenticates, the `LoginCubit` coordinates with `AuthRepository`:

```dart
// lib/features/login/bloc/login_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:hotelyn/core/domain/repository/repository.dart';
import 'package:hotelyn/features/login/models/email.dart';
import 'package:hotelyn/features/login/models/password.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(const LoginState());

  final AuthRepository _authRepository;

  void emailChanged(String value) {
    final email = Email.dirty(value);
    emit(
      state.copyWith(
        email: email,
        isValid: Formz.validate([email, state.password]),
      ),
    );
  }

  void passwordChanged(String value) {
    final password = Password.dirty(value);
    emit(
      state.copyWith(
        password: password,
        isValid: Formz.validate([state.email, password]),
      ),
    );
  }

  Future<void> logInWithCredentials() async {
    final email = Email.dirty(state.email.value);
    final password = Password.dirty(state.password.value);
    emit(
      state.copyWith(
        email: email,
        password: password,
        isValid: Formz.validate([email, password]),
      ),
    );
    if (!state.isValid) return;
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      // Perform login and persist user ID with Clarity tracking
      await _authRepository.login();
      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } on Exception catch (_) {
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
    }
  }
}
```

The `_authRepository.login()` call handles both persistence and Clarity registration in a single operation, keeping the cubit focused on form state management.

## Custom Events for Heatmap Context

Raw heatmaps show interaction patterns, but custom events add semantic context. Tagging sessions with business events lets you filter heatmaps by user behavior—"show me heatmaps only from users who completed a booking."

### Tagging Conversion Events

Use `Clarity.setCustomTag()` to mark significant moments:

```dart
// lib/features/payment/view/payment_page.dart
HotelynButton(
  message: 'Pay Now',
  onPressed: () {
    Clarity.setCustomTag(
      'booking_completed',
      'hotel_grand_plaza',
    );
    // ... complete payment
  },
),
```

On the Clarity dashboard, you can filter session recordings and heatmaps by these tags. This transforms generic interaction data into conversion-specific insights.

### Screen Tracking for Navigation Analysis

Set screen names to segment heatmaps by feature area:

```dart
// lib/features/payment/view/payment_page.dart
@override
Widget build(BuildContext context) {
  Clarity.setCurrentScreenName('payment');
  return Scaffold(
    // ...
  );
}
```

This enables dashboard queries like "show scroll heatmaps for the payment screen" without parsing generic session data.

## Interpreting Heatmap Data

After collecting sessions, the Clarity dashboard presents aggregated heatmap visualizations. Here's how to extract actionable insights.

### Identifying Dead Zones

Cold areas (blue/uncolored) on tap heatmaps indicate UI elements users ignore. Common causes:

- **Low visual hierarchy**: The element doesn't stand out from surrounding content
- **Poor positioning**: Users don't scroll far enough to see it
- **Unclear affordance**: The element doesn't look interactive

Cross-reference with scroll heatmaps—if users never reach an element, the issue is content hierarchy, not the element itself.

### Detecting Rage Taps

Clarity automatically flags sessions with rage taps (rapid repeated taps in the same location). High rage tap rates on specific screens indicate:

- **Unresponsive UI**: Tap handlers are too slow or not registered
- **Misleading affordances**: Elements look tappable but aren't
- **Loading state confusion**: Users don't realize an action is processing

Filter heatmaps to rage-tap sessions to identify exactly where users experience frustration.

### Scroll Depth Analysis

Scroll heatmaps show a gradient from 100% (top) to the percentage of users who scroll to each depth. Key patterns:

- **Sharp drop-off at fold**: Above-the-fold content isn't compelling enough to scroll
- **Gradual decline**: Expected behavior; optimize content order by importance
- **Unexpected plateau**: Users stop at a specific point—look for visual barriers or "false bottoms"

## Performance Considerations

Clarity's SDK is designed for minimal runtime impact, but understanding its resource profile helps with production deployment decisions.

### Resource Footprint

Based on Microsoft's benchmarks:

- **App size increase**: ~800 KB (Android), ~900 KB (iOS)
- **Network usage**: ~10 KiB/second of recording
- **CPU overhead**: Negligible for typical apps; may increase on image-heavy screens during initial asset capture

### Production Configuration

For release builds, ensure logging is disabled:

```dart
final config = ClarityConfig(
  projectId: 'your_project_id',
  logLevel: kReleaseMode ? LogLevel.None : LogLevel.Verbose,
);
```

The `kReleaseMode` check from `package:flutter/foundation.dart` handles this automatically.

### Network Efficiency

Clarity batches and compresses session data before upload. By default, uploads only occur on WiFi. If your user base frequently operates on cellular, consider the trade-off between data freshness and user bandwidth consumption.

## Where to Go From Here

You now have a production-ready heatmap implementation that:

- Captures all user interactions while protecting sensitive data through hierarchical masking
- Tracks authenticated users across sessions with persistent user IDs
- Tags sessions with business events for filtered analysis
- Follows clean architecture patterns with repository-based Clarity integration

To deepen your Clarity implementation:

- Explore the [official Microsoft Clarity documentation](https://learn.microsoft.com/en-us/clarity/mobile-sdk/flutter-sdk) for additional configuration options
- Review [Clarity's privacy guidelines](https://learn.microsoft.com/en-us/clarity/mobile-sdk/mobile-sdk-overview) for GDPR compliance considerations
- Experiment with A/B testing by comparing heatmaps across app versions

The Hotelyn sample project demonstrates all patterns covered in this tutorial. Use it as a reference implementation for your own Clarity integration.
