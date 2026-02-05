import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:formz/formz.dart';
import 'package:go_router/go_router.dart';
import 'package:hotelyn/components/hotelyn_button.dart';
import 'package:hotelyn/components/text_input/hotelyn_text_input.dart';
import 'package:hotelyn/components/theme/hotelyn_colors.dart';
import 'package:hotelyn/core/domain/repository/repository.dart';
import 'package:hotelyn/features/login/bloc/login_cubit.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  static const route = '/login';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(
        authRepository: context.read<AuthRepository>(),
      ),
      child: BlocListener<LoginCubit, LoginState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status.isSuccess) {
            context.go('/home');
          }
        },
        child: const Scaffold(
          body: LoginView(),
        ),
      ),
    );
  }
}

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 60),
              _Header(),
              SizedBox(height: 48),
              _LoginForm(),
              SizedBox(height: 24),
              _SocialLoginSection(),
              SizedBox(height: 24),
              _RegisterText(),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/icons/ic_hotelyn.png',
          height: 80,
          width: 80,
        ),
        const SizedBox(height: 16),
        Text(
          'Hotelyn',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: PrimaryColors.black,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Login to your account',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: GreyColors.grey,
              ),
        ),
      ],
    );
  }
}

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

class _SocialLoginSection extends StatelessWidget {
  const _SocialLoginSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Or login with',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: GreyColors.grey,
                    ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SocialButton(
              icon: FontAwesomeIcons.google,
              onPressed: () {},
              color: Colors.red,
            ),
            const SizedBox(width: 16),
            _SocialButton(
              icon: FontAwesomeIcons.apple,
              onPressed: () {},
              color: Colors.black,
            ),
            const SizedBox(width: 16),
            _SocialButton(
              icon: FontAwesomeIcons.twitter,
              onPressed: () {},
              color: Colors.blue,
            ),
          ],
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.onPressed,
    required this.color,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: GreyColors.grey3),
        ),
        child: Icon(
          icon,
          color: color,
          size: 24,
        ),
      ),
    );
  }
}

class _RegisterText extends StatelessWidget {
  const _RegisterText();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: GreyColors.grey,
              ),
        ),
        GestureDetector(
          onTap: () {},
          child: Text(
            'Register',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: PrimaryColors.blue,
                ),
          ),
        ),
      ],
    );
  }
}
