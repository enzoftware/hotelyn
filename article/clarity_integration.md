# Microsoft Clarity Flutter SDK: Getting Started

<!-- Learn how to integrate Microsoft Clarity analytics into your Flutter application to gain powerful insights into user behavior through session replays, heatmaps, and interaction analytics. -->

Session replay and user analytics have become essential tools for modern app development. Understanding how users interact with your app helps you identify pain points, optimize user flows, and make data-driven decisions to improve the overall user experience.

Microsoft Clarity is a free, privacy-conscious analytics tool that captures user sessions, generates heatmaps, and provides detailed interaction metrics. While Clarity has been widely used for web applications, Microsoft recently released an official Flutter SDK, bringing these powerful analytics capabilities to mobile developers.

In this article, you'll learn how to:

- Set up the Clarity Flutter SDK in your application
- Configure Clarity to capture user sessions and interactions
- Implement privacy controls using masking widgets
- Handle sensitive data appropriately
- Monitor and debug Clarity integration
- Access session replays and heatmaps on the Clarity dashboard

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
  clarity_flutter: ^1.7.1
```

After adding the dependency, run the following command in your terminal to fetch the package:

```bash
flutter pub get
```

This command downloads the Clarity SDK and all its required dependencies, including packages for device information, network connectivity, and image processing.

### Importing Clarity

With the package installed, you need to import it into your main application file. Open your app entrypoint file and add the import statement at the top:

```dart
import 'package:flutter/material.dart';
import 'package:clarity_flutter/clarity_flutter.dart';
```

This import gives you access to all the Clarity classes and widgets you'll use throughout your application.

## Initializing Clarity

Clarity offers two different initialization approaches: using the `ClarityWidget` wrapper or calling `Clarity.initialize()` directly. Each approach has its own use case and benefits.

### Using ClarityWidget (Recommended)

The `ClarityWidget` approach is the recommended method for most applications. It wraps your entire app and ensures Clarity is initialized before any widgets are rendered.

Here's how to set it up in your app entrypoint file:

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

Let's break down what's happening in this code:

1. `_LoginForm` is a private `StatelessWidget` that builds the login form UI
2. `ClarityMask` wraps the entire `Column` containing form fields—this tells Clarity to hide everything inside from session recordings
3. Any child widgets (text fields, buttons, labels) within the `Column` are automatically masked
4. Users interacting with the form will have their input hidden in replays, protecting credentials from being recorded


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

Let's break down what's happening in this code:

1. `ClarityMask` wraps the entire `SingleChildScrollView`, making the whole payment screen hidden by default in session recordings
2. `BookingSummaryCard` is wrapped with `ClarityUnmask` this overrides the parent mask, making the hotel name, dates, and total price visible in replays since this information is non-sensitive
3. `PaymentFormCard` remains masked (no `ClarityUnmask` wrapper), so credit card numbers, CVV, and other payment details are hidden from recordings
4. The "Pay Now" `HotelynButton` is wrapped with `ClarityUnmask` this allows you to see user interactions with the button in heatmaps and session replays without exposing sensitive data
5. This hierarchical approach lets you selectively reveal safe UI elements while keeping sensitive payment information protected


### App-Wide Masking Modes

Beyond individual widgets, Clarity supports app-wide masking modes that automatically mask certain types of content:

- **Strict Mode**: Masks all text and sensitive elements by default
- **Moderate Mode**: Masks passwords, credit cards, and similar sensitive data
- **Permissive Mode**: Only masks explicitly marked elements

You can learn more about these modes in the [Clarity masking documentation](https://learn.microsoft.com/en-us/clarity/mobile-sdk/flutter-sdk).

[SPACE FOR IMAGE: Clarity dashboard showing session recordings]

### Common issues and solutions

**No data appearing on dashboard**: Verify your project ID is correct and that your device has internet connectivity. Data typically appears within 30 minutes to 2 hours.

**Initialization errors**: Check that you're calling `Clarity.initialize()` with a valid BuildContext after the widget is built.

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

Let's break down what's happening in this code:

1. `AuthService` is a service class that handles user authentication logic
2. In `signIn`, after successfully authenticating the user with `_authenticateUser`, we call `Clarity.setCustomUserId(user.id)` to associate all subsequent session data with this specific user
3. The `user.id` should be a unique, non-sensitive identifier (avoid using email addresses or personal information)
4. In `signOut`, after clearing the user session, we call `Clarity.setCustomUserId(null)` to reset tracking back to anonymous mode

## Tracking Screen Names for Heatmaps

One of Clarity's most valuable features is its ability to generate heatmaps showing where users interact most on each screen. For heatmaps to work effectively, Clarity needs to know which screen the user is currently viewing. This is where `Clarity.setCurrentScreenName` becomes essential.

### Why Screen Names Matter

When Clarity captures screenshots for heatmap generation, it groups them by screen name. Without explicit screen names, Clarity may not accurately associate user interactions with the correct screens, resulting in incomplete or fragmented heatmap data.

Setting screen names helps Clarity:

- **Generate accurate heatmaps**: Screenshots are properly grouped by screen, giving you meaningful interaction visualizations
- **Organize session replays**: Screen transitions are clearly labeled in the recording timeline
- **Filter analytics by screen**: Easily analyze user behavior on specific screens in the dashboard
- **Track screen-level metrics**: Measure time spent and interactions per screen

### Implementing setCurrentScreenName

Call `Clarity.setCurrentScreenName` whenever the user navigates to a new screen. The method accepts a string parameter representing the screen name:

```dart
await Clarity.setCurrentScreenName("HomeScreen");
```

### Performance Impact

A common concern when adding analytics tracking is the impact on app performance. The good news is that `Clarity.setCurrentScreenName` has **negligible performance impact** on your application.

Here's why this method is performance-safe:

- **Lightweight operation**: Setting the screen name is a simple string assignment that executes in microseconds
- **No blocking calls**: The method doesn't perform network requests or heavy computations on the main thread
- **Asynchronous processing**: Any screenshot capture or data processing happens on background threads
- **Optimized SDK design**: Clarity's SDK is specifically designed to minimize main thread usage

The actual screenshot capture for heatmaps is handled intelligently by the SDK—it captures screenshots at optimal moments without blocking the UI thread or affecting animations.

### Best Practices for Screen Names

Follow these conventions for consistent and useful screen tracking:

1. **Use descriptive names**: Choose names that clearly identify the screen (e.g., "HotelDetailScreen" instead of "Screen1")
2. **Be consistent**: Use the same naming convention throughout your app (PascalCase, snake_case, etc.)
3. **Include context when needed**: For parameterized screens, include relevant context (e.g., "HotelDetail_Premium" vs "HotelDetail_Standard")
4. **Avoid sensitive data**: Never include user IDs, personal information, or sensitive data in screen names
5. **Keep names concise**: Long screen names can be truncated in the dashboard

```dart
// Good examples
Clarity.setCurrentScreenName("HomeScreen");
Clarity.setCurrentScreenName("BookingConfirmation");
Clarity.setCurrentScreenName("PaymentScreen");

// Avoid these patterns
Clarity.setCurrentScreenName("Screen1");  // Not descriptive
Clarity.setCurrentScreenName("user_123_profile");  // Contains user ID
Clarity.setCurrentScreenName("TheMainHomeScreenWithAllTheHotelsAndSearchFunctionality");  // Too long
```

## Viewing Analytics on the Dashboard

After implementing Clarity and collecting session data, you'll want to analyze user behavior on the Clarity dashboard. This is where all the captured data transforms into actionable insights.

### Accessing Your Dashboard

Navigate to [clarity.microsoft.com](https://clarity.microsoft.com) and sign in with your Microsoft account. Select your project from the projects list to view the dashboard.

The dashboard is organized into several key sections:

- **Dashboard Overview**: Displays high-level metrics including total sessions, pages per session, and average session duration.
- **Recordings**: Shows individual session replays where you can watch exactly how users interacted with your app.
- **Heatmaps**: Visualizes aggregate user interactions showing where users tap, scroll, and engage most frequently.
- **Settings**: Configure Clarity settings, including funnels, masking, and mask events.

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

- **Rage Taps**: When users repeatedly tap the same area quickly, indicating frustration with an unresponsive element.
- **Dead Taps**: Taps on elements that don't respond or provide feedback.
- **Quick Backs**: Users who immediately navigate back, suggesting the destination wasn't what they expected.

You can filter sessions by these signals to prioritize fixing the most frustrating user experiences.


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