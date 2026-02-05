# Microsoft Clarity Flutter SDK: Getting Started

Learn how to integrate Microsoft Clarity analytics into your Flutter application to gain powerful insights into user behavior through session replays, heatmaps, and interaction analytics.

By Enzo Lizama.

Session replay and user analytics have become essential tools for modern app development. Understanding how users interact with your app helps you identify pain points, optimize user flows, and make data-driven decisions to improve the overall user experience.

Microsoft Clarity is a free, privacy-conscious analytics tool that captures user sessions, generates heatmaps, and provides detailed interaction metrics. While Clarity has been widely used for web applications, Microsoft recently released an official Flutter SDK, bringing these powerful analytics capabilities to mobile developers.

In this tutorial, you'll learn how to:

- Set up the Clarity Flutter SDK in your application
- Configure Clarity to capture user sessions and interactions
- Implement privacy controls using masking widgets
- Handle sensitive data appropriately
- Monitor and debug Clarity integration
- Access session replays and analytics on the Clarity dashboard

You'll work through these concepts by integrating Clarity into Hotelyn, a hotel booking application. By the end of this tutorial, you'll be able to track user journeys, identify UX issues, and gain actionable insights from real user behavior.

*Note:* This tutorial assumes you know the basics of Flutter development. If you're new to Flutter, check out [Flutter Tutorial for Beginners](https://docs.flutter.dev/get-started/codelab) on the official Flutter documentation.

## Getting Started

Before diving into the code, you need to set up a Microsoft Clarity account and obtain a project ID. This ID uniquely identifies your application within the Clarity platform.

### Creating a Clarity Project

Visit [clarity.microsoft.com](https://clarity.microsoft.com) and sign in with your Microsoft account. If you don't have one, you can create it for free.

Once signed in, follow these steps:

1. Click on **Add new project** in the Clarity dashboard
2. Enter your project name (e.g., "Hotelyn Mobile App")
3. Select **Mobile App** as the platform
4. Click **Create**

After creating the project, you'll see your **Project ID** on the Settings page. Keep this ID handy as you'll need it for initialization.

[SPACE FOR SCREENSHOT: Clarity Dashboard showing Project ID]

### Understanding the Clarity Flutter SDK

The Clarity Flutter SDK is Microsoft's official package for integrating Clarity analytics into Flutter applications. It supports both Android and iOS platforms and provides several key features:

- **Session Replay**: Record and replay user sessions to see exactly how users interact with your app
- **Heatmaps**: Visualize where users tap, scroll, and interact most frequently
- **User Interactions**: Track rage taps, dead taps, and other user frustration signals
- **Automatic Screen Capture**: Capture screen transitions and user flows without manual instrumentation
- **Privacy Controls**: Built-in widgets for masking sensitive information

The SDK captures data automatically once initialized and uploads sessions periodically when the device has internet connectivity. This means you'll start seeing data on your Clarity dashboard shortly after users begin interacting with your app.

*Note:* The SDK only uploads data when the device is connected to the internet. Offline session capture is not currently supported.

## Adding Clarity to Your Project

Now that you understand what Clarity offers, it's time to integrate it into your Flutter application. You'll start by adding the dependency and then configure the SDK for your specific needs.

### Installing the Package

Open your `pubspec.yaml` file and add the `clarity_flutter` dependency under the `dependencies` section:

```yaml
dependencies:
  flutter:
    sdk: flutter
  clarity_flutter: ^1.0.0
```

After adding the dependency, run the following command in your terminal to fetch the package:

```bash
flutter pub get
```

This command downloads the Clarity SDK and all its required dependencies, including packages for device information, network connectivity, and image processing.

### Importing Clarity

With the package installed, you need to import it into your main application file. Open `lib/main.dart` and add the import statement at the top:

```dart
import 'package:flutter/material.dart';
import 'package:clarity_flutter/clarity_flutter.dart';
```

This import gives you access to all the Clarity classes and widgets you'll use throughout your application.

## Initializing Clarity

Clarity offers two different initialization approaches: using the `ClarityWidget` wrapper or calling `Clarity.initialize()` directly. Each approach has its own use case and benefits.

### Using ClarityWidget (Recommended)

The `ClarityWidget` approach is the recommended method for most applications. It wraps your entire app and ensures Clarity is initialized before any widgets are rendered.

Here's how to set it up in your `main.dart` file:

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  final config = ClarityConfig(
    projectId: "YOUR_PROJECT_ID_HERE",
    logLevel: LogLevel.Info,
  );
  
  runApp(
    ClarityWidget(
      app: const HotelyenApp(),
      clarityConfig: config,
    ),
  );
}
```

Let's break down what's happening in this code:

1. `WidgetsFlutterBinding.ensureInitialized()` ensures Flutter is ready before any initialization code runs
2. `ClarityConfig` creates a configuration object with your project ID and logging preferences
3. `ClarityWidget` wraps your application and handles initialization automatically

[SPACE FOR CODE: Example from actual Hotelyn main.dart implementation]

### Using Clarity.initialize()

Alternatively, you can initialize Clarity manually using `Clarity.initialize()`. This approach gives you more control over when initialization happens but requires a valid `BuildContext`.

Here's an example of manual initialization inside a StatefulWidget:

```dart
class HotelyenApp extends StatefulWidget {
  const HotelyenApp({super.key});

  @override
  State<HotelyenApp> createState() => _HotelyenAppState();
}

class _HotelyenAppState extends State<HotelyenApp> {
  @override
  void initState() {
    super.initState();
    _initializeClarity();
  }

  void _initializeClarity() {
    final config = ClarityConfig(
      projectId: "YOUR_PROJECT_ID_HERE",
      logLevel: LogLevel.Info,
    );
    
    Clarity.initialize(context, config);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hotelyn',
      home: const HomeScreen(),
    );
  }
}
```

The key difference here is that you're responsible for calling initialization at the right time, typically in the `initState()` method of your root widget.

*Important:* Always call `Clarity.initialize()` on the UI Isolate with a valid BuildContext. Calling it before the widget is built will result in an error.

## Configuring Clarity Settings

The `ClarityConfig` class provides several options to customize how Clarity behaves in your application. Understanding these options helps you balance data collection with performance and user privacy.

### Essential Configuration Options

Here's a detailed look at the available configuration parameters:

```dart
final config = ClarityConfig(
  projectId: "YOUR_PROJECT_ID_HERE",          // Required: Your Clarity project ID
  logLevel: LogLevel.Info,                     // Optional: Controls SDK logging
);
```

Let's examine each parameter:

**projectId**: This is your unique Clarity project identifier. You can find this on the Settings page of your Clarity dashboard. This parameter is required and the SDK won't initialize without it.

**logLevel**: Controls the verbosity of Clarity's debug output. This is particularly useful during development for troubleshooting integration issues. The available log levels are:

- `LogLevel.Verbose`: Extremely detailed debug information
- `LogLevel.Debug`: Debug information for development
- `LogLevel.Info`: Informational messages (recommended for development)
- `LogLevel.Warn`: Warning messages only
- `LogLevel.Error`: Error messages only
- `LogLevel.None`: No logging (automatically used in production builds)

During development, you want verbose logging to catch any issues early. In production, you want minimal overhead. Here's a recommended pattern:

```dart
final config = ClarityConfig(
  projectId: "YOUR_PROJECT_ID_HERE",
  logLevel: kDebugMode ? LogLevel.Verbose : LogLevel.None,
);
```

This approach automatically adjusts the log level based on whether you're running a debug or release build.


## Protecting User Privacy with Masking

Privacy is paramount when collecting user analytics. Clarity provides masking widgets that let you hide sensitive information from session recordings while still capturing the overall user flow.

### Understanding Masking Widgets

The Clarity SDK includes two essential widgets for privacy control:

- `ClarityMask`: Hides its child widget from recordings
- `ClarityUnmask`: Makes its child visible within a masked parent

These widgets work hierarchically. When you wrap a widget tree with `ClarityMask`, everything inside becomes hidden in recordings. You can then selectively unmask specific child widgets that are safe to record.

### Masking Sensitive Data

Any screen or widget that displays sensitive user information should be masked. Common examples include:

- Login and registration forms
- Payment information screens
- Personal identification numbers
- Credit card details
- Passwords and security codes

Here's how to mask a login screen:

```dart
// lib/features/login/view/login_page.dart

class _LoginForm extends StatelessWidget {
  const _LoginForm();

  @override
  Widget build(BuildContext context) {
    return ClarityMask(
      child: Column(
        children: [
          // Login form widgets
          ...
        ],
      ),
    );
  }
}
```

In this example, the entire login form is wrapped with `ClarityMask`. When users enter their credentials, the session replay will show a masked area instead of the actual input fields.


### Selective Unmasking

Sometimes you want to mask a large section but keep certain non-sensitive elements visible for analytics purposes. This is where `ClarityUnmask` becomes useful.

Here's an example of a payment screen where you mask the credit card details but keep the booking summary visible:

```dart
class _PaymentBody extends StatelessWidget {
  const _PaymentBody();

  @override
  Widget build(BuildContext context) {
    // Payment screen is masked
    return ClarityMask(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Booking summary is visible
            const ClarityUnmask(
              child: BookingSummaryCard(
                hotelName: 'Grand Plaza Hotel',
                checkIn: 'Dec 15, 2024',
                checkOut: 'Dec 18, 2024',
                totalPrice: r'$690.30',
              ),
            ),
            const SizedBox(height: 16),
            const PaymentFormCard(),
            const SizedBox(height: 32),
            // Pay now button is visible
            ClarityUnmask(
              child: HotelynButton(
                message: 'Pay Now',
                onPressed: () {
                  ...
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

This approach gives you granular control over what appears in session recordings. You can see the user's journey through the payment process without exposing their payment credentials.

### App-Wide Masking Modes

Beyond individual widgets, Clarity supports app-wide masking modes that automatically mask certain types of content:

- **Strict Mode**: Masks all text and sensitive elements by default
- **Moderate Mode**: Masks passwords, credit cards, and similar sensitive data
- **Permissive Mode**: Only masks explicitly marked elements

You can learn more about these modes in the [Clarity masking documentation](https://learn.microsoft.com/en-us/clarity/mobile-sdk/flutter-sdk).

[SPACE FOR IMAGE: Clarity dashboard showing session recordings]

### Debugging Integration Issues

If you're not seeing data on the Clarity dashboard, follow these troubleshooting steps:

First, enable verbose logging to see detailed SDK activity:

```dart
final config = ClarityConfig(
  projectId: "YOUR_PROJECT_ID_HERE",
  logLevel: LogLevel.Verbose,
);
```

Then filter your device logs for Clarity-specific messages. In Android Studio, use the Logcat filter:

```
[Clarity]
```

[SPACE FOR SCREENSHOT: Android Studio Logcat showing Clarity logs]

Common issues and solutions:

**No data appearing on dashboard**: Verify your project ID is correct and that your device has internet connectivity. Data typically appears within 30 minutes to 2 hours.

**Initialization errors**: Check that you're calling `Clarity.initialize()` with a valid BuildContext after the widget is built.

**Session not uploading**: Ensure the device is connected to an unmetered network, or enable `allowMeteredNetworkUsage` in your configuration.

**Excessive logging in production**: Verify that `logLevel` is set to `LogLevel.None` for release builds.

## Setting Custom User Identifiers

By default, Clarity generates anonymous user IDs automatically. However, if you have your own user authentication system, you can set custom user IDs to track users across sessions and devices.

### Why Use Custom User IDs

Custom user IDs provide several benefits:

- Track the same user across multiple sessions and devices
- Correlate Clarity data with your backend analytics
- Filter sessions by specific users on the dashboard
- Identify problematic user journeys for specific customer segments

### Setting the User ID

You can set a custom user ID at any time after initialization:

```dart
await Clarity.setCustomUserId("user_12345");
```

Here's a practical example of setting the user ID after successful authentication:

```dart
class AuthService {
  Future<void> signIn(String email, String password) async {
    // Perform authentication
    final user = await _authenticateUser(email, password);
    
    // Set Clarity user ID after successful login
    await Clarity.setCustomUserId(user.id);
  }
  
  Future<void> signOut() async {
    // Clear user session
    await _clearUserSession();
    
    // Optionally reset to anonymous tracking
    await Clarity.setCustomUserId(null);
  }
}
```

[SPACE FOR CODE: Example from Hotelyn authentication flow]

### User ID Requirements

The custom user ID must meet these requirements:

1. Cannot be an empty string
2. Must be base36 encoded
3. Should be smaller than "1Z141Z4"

If you don't provide a user ID or pass `null`, Clarity will generate a unique anonymous ID automatically.

## Sending Custom Events

While Clarity automatically tracks screen transitions and user interactions, you might want to track specific business events that matter to your application. Custom events let you mark important moments in the user journey.

### When to Use Custom Events

Custom events are useful for tracking:

- Key conversion points (booking completed, payment successful)
- Feature usage (filter applied, search performed)
- Error conditions (payment failed, network timeout)
- User flows (onboarding completed, profile updated)

### Implementing Custom Events

The SDK provides a method for sending custom events with optional tags:

```dart
await Clarity.setCustomTag("checkout_initiated", "premium_room");
```

Here's a practical example tracking the hotel booking flow:

```dart
class BookingService {
  Future<void> searchHotels(String location, DateTime checkIn) async {
    // Track search event
    await Clarity.setCustomTag("hotel_search", location);
    
    // Perform search
    final results = await _performSearch(location, checkIn);
    
    return results;
  }
  
  Future<void> completeBooking(Booking booking) async {
    try {
      // Process booking
      await _processPayment(booking);
      
      // Track successful booking
      await Clarity.setCustomTag(
        "booking_completed", 
        "hotel_${booking.hotelId}"
      );
    } catch (e) {
      // Track booking failure
      await Clarity.setCustomTag("booking_failed", e.toString());
      rethrow;
    }
  }
}
```

[SPACE FOR CODE: Example from Hotelyn booking flow]

Custom tags appear in the Clarity dashboard alongside session replays, allowing you to filter and analyze sessions based on specific events.

## Viewing Analytics on the Dashboard

After implementing Clarity and collecting session data, you'll want to analyze user behavior on the Clarity dashboard. This is where all the captured data transforms into actionable insights.

### Accessing Your Dashboard

Navigate to [clarity.microsoft.com](https://clarity.microsoft.com) and sign in with your Microsoft account. Select your project from the projects list to view the dashboard.

The dashboard is organized into several key sections:

**Dashboard Overview**: Displays high-level metrics including total sessions, pages per session, and average session duration.

**Recordings**: Shows individual session replays where you can watch exactly how users interacted with your app.

**Heatmaps**: Visualizes aggregate user interactions showing where users tap, scroll, and engage most frequently.

**Insights**: Automatically identifies user frustration signals like rage taps and dead taps.

[SPACE FOR SCREENSHOT: Clarity dashboard overview]

### Analyzing Session Recordings

Session recordings are one of Clarity's most powerful features. They let you see your app through your users' eyes.

To watch a recording:

1. Click on **Recordings** in the left navigation
2. Select any session from the list
3. Click the play button to watch the replay

The recording shows every screen transition, tap, scroll, and interaction the user performed. You can speed up playback, skip idle time, and focus on specific parts of the session.

[SPACE FOR SCREENSHOT: Session recording playback]

### Understanding Heatmaps

Heatmaps aggregate data from many sessions to show patterns in user behavior. They use color coding to indicate interaction frequency:

- **Red areas**: High interaction (users tap or focus here frequently)
- **Yellow areas**: Moderate interaction
- **Blue areas**: Low interaction
- **Uncolored areas**: No interaction

Use heatmaps to:

- Identify which UI elements users engage with most
- Discover buttons or links users ignore
- Optimize screen layouts based on actual usage patterns
- A/B test different designs and compare heatmaps

[SPACE FOR SCREENSHOT: Heatmap visualization]

### Identifying User Frustration

Clarity automatically detects frustration signals:

**Rage Taps**: When users repeatedly tap the same area quickly, indicating frustration with an unresponsive element.

**Dead Taps**: Taps on elements that don't respond or provide feedback.

**Quick Backs**: Users who immediately navigate back, suggesting the destination wasn't what they expected.

You can filter sessions by these signals to prioritize fixing the most frustrating user experiences.

## Performance Considerations

While Clarity is designed to have minimal impact on app performance, understanding its resource usage helps you make informed decisions about when and how to use it.

### Resource Usage

Based on Microsoft's testing, the Clarity Flutter SDK has the following impact:

**App Size**: Increases Android APK size by approximately 800 KB and iOS IPA size by approximately 900 KB.

**CPU Usage**: Main thread usage varies based on your app's nature. Most apps see negligible CPU impact during normal operation.

**Network Usage**: Sessions consume approximately 10 KiB per second of recording. Image-heavy apps may experience higher initial traffic due to asset uploading.

**Storage**: Clarity buffers data on disk before uploading. The SDK automatically deletes old buffered data periodically.

### Best Practices

To minimize performance impact:

**Use appropriate log levels**: Set `LogLevel.None` for production builds to eliminate logging overhead.

**Mask large sections sparingly**: While masking is lightweight, masking and unmasking complex widget trees repeatedly can add overhead.

**Avoid masking in hot paths**: Don't toggle masking during animations or rapidly changing screens.

**Monitor memory usage**: Use Flutter DevTools to ensure Clarity isn't causing memory leaks in your specific use case.

**Test on representative devices**: Performance characteristics vary across devices and Android/iOS versions.

### Network Efficiency

Clarity is designed to be network-efficient:

- Sessions are batched and compressed before upload
- Uploads happen on background threads
- By default, uploads only occur on WiFi
- Failed uploads are retried automatically

If network usage is a concern for your users, keep the default `allowMeteredNetworkUsage: false` configuration.

## Where to Go From Here?

Congratulations! You've successfully integrated Microsoft Clarity into your Flutter application. You now have the tools to track user sessions, identify UX pain points, and make data-driven decisions to improve your app.

You can download the completed project using the *Download Materials* button at the top or bottom of this tutorial. This includes the full Hotelyn app with Clarity integration and privacy masking implemented.

### Next Steps

To deepen your Clarity knowledge:

- Explore the [official Microsoft Clarity documentation](https://learn.microsoft.com/en-us/clarity/mobile-sdk/flutter-sdk) for advanced features
- Review [Clarity's privacy guidelines](https://learn.microsoft.com/en-us/clarity/mobile-sdk/mobile-sdk-overview) to ensure GDPR and privacy compliance
- Experiment with different masking strategies for your specific use case
- Set up custom dashboards and alerts based on your key metrics

### Additional Resources

Want to learn more about Flutter analytics and monitoring? Check out these resources:

- [Firebase Analytics for Flutter](https://firebase.google.com/docs/analytics/get-started?platform=flutter): Another powerful analytics solution
- [Flutter Performance Best Practices](https://docs.flutter.dev/perf/best-practices): Optimize your app's performance
- [User Privacy in Flutter](https://docs.flutter.dev/security/security-best-practices): Learn about privacy best practices

If you have questions or want to share your Clarity integration experience, join the discussion in the comments below!